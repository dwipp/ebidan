const COLLECTION_NAME = "puskesmas";        
const BATCH_SIZE = 500;
const MAX_RETRIES = 3; 
const RETRY_DELAY = 5000; 

function getFirebaseConfig() {
  const props = PropertiesService.getScriptProperties();
  const env = props.getProperty('ENV') || 'dev';

  if (env !== 'dev' && env !== 'prod') {
    throw new Error('ENV harus dev atau prod');
  }

  const projectId = props.getProperty(
    env === 'dev' ? 'DEV_PROJECT_ID' : 'PROD_PROJECT_ID'
  );

  const serviceAccountJson = props.getProperty(
    env === 'dev'
      ? 'DEV_SERVICE_ACCOUNT_JSON'
      : 'PROD_SERVICE_ACCOUNT_JSON'
  );

  if (!projectId || !serviceAccountJson) {
    throw new Error(`Config ${env} belum lengkap`);
  }

  return {
    env,
    projectId,
    serviceAccount: JSON.parse(serviceAccountJson),
  };
}


const HEADER_MAP = {
  "KODE": "id",
  "PUSKESMAS": "nama",
  "KECAMATAN": "kecamatan",
  "KABUPATEN": "kabupaten",
  "PROVINSI": "provinsi",
};

// ---------------- Helper Functions ----------------

function generateKeywords(text) {
  if (!text) return [];
  
  // Pisahkan kata
  const words = text.toLowerCase().trim().split(/\s+/).filter(w => w);

  const keywords = new Set();

  // 1. Masukkan kata satuan
  words.forEach(w => keywords.add(w));

  // 2. Masukkan kombinasi berurutan (n-grams)
  for (let i = 0; i < words.length; i++) {
    let phrase = words[i];
    for (let j = i + 1; j < words.length; j++) {
      phrase += " " + words[j];
      keywords.add(phrase);
    }
  }

  // 3. Masukkan semua permutasi (misal "baru banjar")
  if (words.length > 1) {
    const permute = (arr, m = []) => {
      if (arr.length === 0) {
        if (m.length > 1) {
          keywords.add(m.join(" "));
        }
      } else {
        for (let i = 0; i < arr.length; i++) {
          const curr = arr.slice();
          const next = curr.splice(i, 1);
          permute(curr.slice(), m.concat(next));
        }
      }
    };
    permute(words);
  }

  // 4. Tambahan: "puskesmas <word>"
  words.forEach(w => {
    keywords.add(`puskesmas ${w}`);
  });

  return Array.from(keywords);
}


function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}

// ---------------- JWT & Access Token ----------------

function getAccessToken() {
  const config = getFirebaseConfig();
  const privateKey = config.serviceAccount.private_key.replace(/\\n/g, '\n');
  const now = Math.floor(Date.now() / 1000);
  const jwtHeader = { alg: "RS256", typ: "JWT" };
  const jwtClaimSet = {
    iss: config.serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/datastore",
    aud: config.serviceAccount.token_uri,
    exp: now + 3600,
    iat: now
  };

  const base64Encode = (obj) => Utilities.base64EncodeWebSafe(JSON.stringify(obj)).replace(/=+$/, "");
  const encodedHeader = base64Encode(jwtHeader);
  const encodedClaim = base64Encode(jwtClaimSet);
  const signatureInput = encodedHeader + "." + encodedClaim;

  // Pakai key mentah dari JSON, jangan diubah
  const signature = Utilities.computeRsaSha256Signature(signatureInput, privateKey);
  const encodedSignature = Utilities.base64EncodeWebSafe(signature).replace(/=+$/, "");
  const jwt = `${signatureInput}.${encodedSignature}`;

  const tokenResponse = UrlFetchApp.fetch(config.serviceAccount.token_uri, {
    method: "post",
    payload: {
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt
    }
  });

  const token = JSON.parse(tokenResponse.getContentText());
  return token.access_token;
}

// ---------------- Upload Batch ----------------

function uploadBatch(writes) {
  const config = getFirebaseConfig();
  const token = getAccessToken();
  const url = `https://firestore.googleapis.com/v1/projects/${config.projectId}/databases/(default)/documents:batchWrite`;
  
  const options = {
    method: "post",
    contentType: "application/json",
    headers: { Authorization: `Bearer ${token}` },
    payload: JSON.stringify({ writes }),
    muteHttpExceptions: true
  };

  const response = UrlFetchApp.fetch(url, options);
  return response.getContentText();
}

function sendBatchWithRetry(writes, batchIndex) {
  let attempt = 0;
  while (attempt < MAX_RETRIES) {
    try {
      const result = uploadBatch(writes);
      Logger.log(`Batch ${batchIndex + 1} result: ${result}`);
      return true;
    } catch (e) {
      Logger.log(`Batch ${batchIndex + 1} error: ${e}. Retry ${attempt + 1}`);
      attempt++;
      Utilities.sleep(RETRY_DELAY * attempt);
    }
  }
  Logger.log(`Batch ${batchIndex + 1} failed after ${MAX_RETRIES} attempts.`);
  return false;
}

function updateProgress(message) {
  const template = HtmlService.createHtmlOutput(`<script>
    document.getElementById("progress").innerText = "${message}";
  </script>`);
  SpreadsheetApp.getUi().showModelessDialog(template, "Upload Progress");
}

function createResumeTrigger() {
  ScriptApp.newTrigger("syncToFirestoreBatchWithResume")
    .timeBased()
    .after(30 * 1000) // 30 detik ke depan
    .create();
}

function deleteAllResumeTriggers() {
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(trigger => {
    if (trigger.getHandlerFunction() === "syncToFirestoreBatchWithResume") {
      ScriptApp.deleteTrigger(trigger);
    }
  });
}



// ---------------- Main Sync Function ----------------

function syncToFirestoreBatchWithResume() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Puskesmas");
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  
  const rowChunks = chunkArray(rows, BATCH_SIZE);
  const totalBatches = rowChunks.length;

  const userProps = PropertiesService.getUserProperties();
  let lastBatchIndex = parseInt(userProps.getProperty("LAST_BATCH_INDEX")) || 0;

  const html = HtmlService.createHtmlOutput(`<div id="progress">Memulai sinkronisasi...</div>`)
      .setWidth(300).setHeight(80);
  SpreadsheetApp.getUi().showModelessDialog(html, 'Upload Progress');

  const startTime = Date.now();
  const MAX_RUNTIME = 5 * 60 * 1000; // berhenti sebelum limit 6 menit

  for (let batchIndex = lastBatchIndex; batchIndex < totalBatches; batchIndex++) {
    const chunk = rowChunks[batchIndex];
    const writes = [];
    const config = getFirebaseConfig();

    chunk.forEach(row => {
      const docId = row[0];
      if (!docId) return;

      let fields = {};
      headers.forEach((header, i) => {
        const fieldName = HEADER_MAP[header];
        if (!fieldName) return;
        fields[fieldName] = { stringValue: String(row[i] || "") };
      });

      const nama = String(row[headers.indexOf("PUSKESMAS")] || "");
      const keywords = generateKeywords(nama);
      fields["keywords"] = { arrayValue: { values: keywords.map(k => ({ stringValue: k })) } };

      writes.push({
        update: {
          name: `projects/${config.projectId}/databases/(default)/documents/${COLLECTION_NAME}/${docId}`,
          fields
        }
      });
    });

    if (writes.length > 0) {
      updateProgress(`Batch ${batchIndex + 1}/${totalBatches} sedang dikirim...`);
      const success = sendBatchWithRetry(writes, batchIndex);
      if (success) {
        userProps.setProperty("LAST_BATCH_INDEX", batchIndex + 1);
        Logger.log(`✅ Batch ${batchIndex + 1} dari ${totalBatches} selesai`);
      } else {
        Logger.log(`❌ Batch ${batchIndex + 1} gagal setelah retry`);
        updateProgress(`Batch ${batchIndex + 1} gagal. Hentikan eksekusi.`);
        break;
      }
    }

    // Cek waktu eksekusi, kalau hampir habis → stop & buat trigger
    if (Date.now() - startTime > MAX_RUNTIME) {
      Logger.log(`⏳ Waktu hampir habis, stop di batch ${batchIndex + 1}. Akan lanjut otomatis.`);
      updateProgress(`Pause di batch ${batchIndex + 1}, lanjut otomatis sebentar lagi...`);
      createResumeTrigger();
      return;
    }
  }

  // Semua batch selesai
  updateProgress("Sinkronisasi selesai!");
  userProps.deleteProperty("LAST_BATCH_INDEX");
  deleteAllResumeTriggers();
  Logger.log("🎉 Semua batch berhasil diupload.");
}

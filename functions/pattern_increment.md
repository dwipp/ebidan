flowchart TD
    %% Start Event
    K1["Firestore Event: kehamilan onCreate"]
    K2["Firestore Event: bumil onCreate"]
    K3["Firestore Event: kunjungan onCreate"]
    K4["Firestore Event: kehamilan onUpdate (persalinan)"]

    %% Get Statistics Doc
    G1["Ambil statistics doc bidan"]
    
    %% Ensure Month Structure
    E1["Pastikan by_month[currentMonth] ada"]
    
    %% Increment Logic
    I1["Increment sesuai tipe:\n- kehamilan.all_bumil_count\n- pasien.total\n- kunjungan.k1/k2/.../k6\n- persalinan.total"]
    
    %% Limit 13 Months
    L1["Cek total bulan di by_month > 13\nHapus bulan tertua jika perlu"]
    
    %% Update Last Month
    U1["Update last_updated_month = currentMonth"]
    
    %% Save
    S1["Simpan kembali ke Firestore (merge:true)"]
    
    %% Logging
    Log["Catat log: increment, deleted month, total bulan tersimpan"]

    %% Connections
    K1 --> G1
    K2 --> G1
    K3 --> G1
    K4 --> G1

    G1 --> E1
    E1 --> I1
    I1 --> L1
    L1 --> U1
    U1 --> S1
    S1 --> Log

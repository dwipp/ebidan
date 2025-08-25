import 'package:ebidan/logic/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eBidan"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Kembali ke login screen
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed(AppRouter.pilihBumil, arguments: {'state': 'kunjungan'});
        },
        backgroundColor: Colors.lightBlue[100],
        child: Icon(Icons.add),
      ),
      body: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: Container(
              color: Colors.teal[200],
              child: Text("Total Customer"),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: Container(
              color: Colors.teal[200],
              child: Text("Total Customer"),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: InkWell(
              child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, state) {
                  return Container(
                    color: state.connected ? Colors.lime[200] : Colors.red[300],
                    child: Text("sync"),
                  );
                },
              ),
              onTap: () {},
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 2,
            child: Container(
              color: Colors.teal[200],
              child: Text("Total Customer"),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: Container(
              color: Colors.teal[200],
              child: Text("Total Customer"),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: InkWell(
              child: Container(
                color: Colors.teal[200],
                child: Text("Data Bumil"),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRouter.pilihBumil,
                  arguments: {'state': 'bumil'},
                );
              },
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: Container(
              color: Colors.teal[200],
              child: Text("Total Customer"),
            ),
          ),
        ],
      ),
    );
  }
}

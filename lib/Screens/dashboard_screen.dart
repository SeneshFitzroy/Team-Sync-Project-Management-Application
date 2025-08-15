import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../blocs/project_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Dashboard'),
        actions: [
          CircleAvatar(
            backgroundColor: AppTheme.lightBlue,
            child: const Icon(Icons.person, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.projects.length + 1,
              itemBuilder: (context, index) {
                if (index == state.projects.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to create project
                      },
                      child: const Text('Create New Project'),
                    ),
                  );
                }
                
                final project = state.projects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: project.progress / 100,
                          backgroundColor: AppTheme.lightGray,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 8),
                        Text('${project.progress.toInt()}%'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No projects found'));
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../projects/data/models/project_model.dart';

class DashboardTopBar extends StatefulWidget {
  final String greeting;
  final String subtitle;
  final List<ProjectModel>? projects;
  final ProjectModel? selectedProject;
  final Function(ProjectModel?)? onProjectChanged;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddProject;
  final bool isSuperAdmin;

  const DashboardTopBar({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.projects,
    this.selectedProject,
    this.onProjectChanged,
    this.onProfileTap,
    this.onAddProject,
    this.isSuperAdmin = false,
  });

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  late TextEditingController _searchController;
  late List<ProjectModel> _filteredProjects;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredProjects = widget.projects ?? [];
  }

  @override
  void didUpdateWidget(DashboardTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) {
      _filteredProjects = widget.projects ?? [];
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = widget.projects ?? [];
      } else {
        _filteredProjects = (widget.projects ?? [])
            .where((project) =>
                project.name.toLowerCase().contains(query.toLowerCase()) ||
                (project.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  void _showProjectsBottomSheet(BuildContext context) {
    _searchController.clear();
    _filteredProjects = widget.projects ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Project',
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              // Search field (Fixed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setModalState(() {
                                _filteredProjects = widget.projects ?? [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (query) {
                    setModalState(() {
                      _filterProjects(query);
                    });
                  },
                ),
              ),
              // Scrollable project list
              Expanded(
                child: widget.projects != null && widget.projects!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = _filteredProjects[index];
                          final isSelected = widget.selectedProject?.id == project.id;
                          return ListTile(
                            title: Text(project.name),
                            subtitle: Text(project.description ?? ''),
                            selected: isSelected,
                            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                            leading: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.primary)
                                : const Icon(Icons.circle_outlined),
                            onTap: () {
                              widget.onProjectChanged?.call(project);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          _filteredProjects.isEmpty && _searchController.text.isNotEmpty
                              ? 'No projects found'
                              : 'No projects available',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
              ),
              // Add Project button (Fixed at bottom)
              if (widget.isSuperAdmin)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onAddProject?.call();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.greeting,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.textOnPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.85)),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showProjectsBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.selectedProject?.name ?? 'Select Project',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

# Add Project Feature Implementation

## Overview
Added "Add Project" button to the projects bottom sheet that allows users to create new projects directly from the project selector. The feature includes a dialog for entering project name and description, with automatic API integration.

## Feature Details

### User Flow
```
1. User taps on project selector (dashboard header)
2. Projects bottom sheet opens showing list of projects
3. User taps "+" (Add Project) button in top-right corner
4. Add Project dialog opens with two input fields:
   - Project Name (required)
   - Description (optional)
5. User enters project details and taps "Create"
6. Loading indicator appears on button
7. API call to create project is made
8. On success:
   - New project is added to projects list
   - New project is automatically selected
   - Success toast is shown
   - Projects bottom sheet reopens showing updated list
9. On failure:
   - Error toast is shown with error message
   - Dialog remains open for retry
```

## Implementation Details

### Modified Files

#### [`lib/features/home/presentation/pages/home_page.dart`](lib/features/home/presentation/pages/home_page.dart)

**Changes to `_showProjectSelector()` method (lines 96-178):**
- Updated header from simple Text to Row with title and add button
- Added IconButton with `Icons.add_circle_outline` icon
- Button positioned in top-right corner using `MainAxisAlignment.spaceBetween`
- On button tap: closes bottom sheet and opens add project dialog

**New `_showAddProjectDialog()` method (lines 180-268):**
- Creates AlertDialog with two TextFields:
  - `projectNameController` - for project name (required)
  - `projectDescriptionController` - for project description (optional)
- Dialog actions:
  - Cancel button - closes dialog without action
  - Create button - validates and submits form
- Form validation:
  - Project name is required (shows error toast if empty)
  - Description is optional
- Loading state management:
  - `isLoading` flag controls button state and field enabled status
  - Loading indicator replaces button text during submission
- API integration:
  - Calls `ProjectsRemoteDataSourceImpl().createProject()`
  - Passes trimmed project name and description
- Success handling:
  - Adds new project to `_projects` list
  - Sets new project as `_selectedProject`
  - Closes dialog
  - Shows success toast
  - Reopens projects bottom sheet with updated list
- Error handling:
  - Catches exceptions and shows error toast
  - Keeps dialog open for retry
  - Resets loading state

### Key Features

1. **Input Validation**
   - Project name is required
   - Shows error toast if validation fails
   - Description is optional

2. **Loading State**
   - Button shows loading spinner during API call
   - Text fields are disabled during loading
   - Cancel button is disabled during loading

3. **Error Handling**
   - Catches API exceptions
   - Shows user-friendly error messages
   - Allows retry without closing dialog

4. **Auto-Selection**
   - Newly created project is automatically selected
   - User doesn't need to manually select it

5. **UI/UX**
   - Smooth dialog transitions
   - Visual feedback during loading
   - Success confirmation with toast
   - Automatic bottom sheet refresh

## API Integration

### Endpoint
```
POST /projects/
Content-Type: application/json

Request Body:
{
  "name": "Project Name",
  "description": "Project Description"
}

Response (201/200):
{
  "id": "project_id",
  "name": "Project Name",
  "description": "Project Description",
  "createdAt": "2024-10-23T10:00:00Z",
  ...
}
```

### Data Source Method
Uses existing `ProjectsRemoteDataSourceImpl.createProject()` method:
```dart
Future<ProjectModel> createProject({
  required String name,
  required String description,
})
```

## UI Components

### Add Project Button
- **Icon**: `Icons.add_circle_outline`
- **Position**: Top-right corner of bottom sheet header
- **Tooltip**: "Add Project"
- **Style**: IconButton with default styling

### Add Project Dialog
- **Title**: "Add New Project"
- **Content**: Two TextFields with labels and hints
- **Actions**: Cancel and Create buttons
- **Loading State**: Button shows CircularProgressIndicator

### Input Fields
1. **Project Name**
   - Label: "Project Name"
   - Hint: "Enter project name"
   - Type: Single-line text
   - Required: Yes
   - Border: OutlineInputBorder

2. **Description**
   - Label: "Description (Optional)"
   - Hint: "Enter project description"
   - Type: Multi-line text (3 lines)
   - Required: No
   - Border: OutlineInputBorder

## State Management

### Local State Variables
- `projectNameController` - TextEditingController for project name
- `projectDescriptionController` - TextEditingController for description
- `isLoading` - Boolean flag for loading state

### Parent State Updates
- `_projects` - List updated with new project
- `_selectedProject` - Set to newly created project

## Error Handling

### Validation Errors
- Empty project name: Shows "Project name is required" error toast

### API Errors
- Network errors: Shows "Failed to create project: [error message]" error toast
- Server errors: Shows "Failed to create project: [error message]" error toast
- Timeout errors: Shows "Failed to create project: [error message]" error toast

### Recovery
- Dialog remains open on error
- User can modify inputs and retry
- Loading state is reset on error

## Testing Checklist

- [ ] Add Project button appears in projects bottom sheet
- [ ] Clicking button opens Add Project dialog
- [ ] Dialog has two input fields (name and description)
- [ ] Cancel button closes dialog without action
- [ ] Create button is disabled when project name is empty
- [ ] Error toast appears when trying to create without name
- [ ] Loading spinner appears on Create button during submission
- [ ] Text fields are disabled during loading
- [ ] Cancel button is disabled during loading
- [ ] On success: New project is added to list
- [ ] On success: New project is automatically selected
- [ ] On success: Success toast is shown
- [ ] On success: Projects bottom sheet reopens with updated list
- [ ] On failure: Error toast is shown with error message
- [ ] On failure: Dialog remains open for retry
- [ ] On failure: Loading state is reset
- [ ] Project name and description are trimmed before submission
- [ ] Dialog closes after successful project creation

## Code Quality

- ✅ No compilation errors
- ✅ Flutter analyze passes (only pre-existing info-level warnings)
- ✅ Proper error handling in all code paths
- ✅ Loading state managed correctly
- ✅ Input validation implemented
- ✅ User feedback with toasts
- ✅ Automatic UI refresh after creation

## Future Enhancements

1. **Form Validation**
   - Add real-time validation feedback
   - Show validation errors inline instead of just on submit

2. **Project Details**
   - Add more fields (status, category, etc.)
   - Add project image/icon upload

3. **Duplicate Prevention**
   - Check for duplicate project names
   - Show warning if name already exists

4. **Permissions**
   - Check user permissions before showing add button
   - Only show for Super Admin or Admin users

5. **Keyboard Handling**
   - Auto-focus on project name field
   - Submit on Enter key press

6. **Accessibility**
   - Add semantic labels
   - Improve screen reader support

## Dependencies

- `flutter/material.dart` - UI components
- `ProjectsRemoteDataSourceImpl` - API integration
- `AppToast` - Toast notifications
- `AppColors` - Theme colors

## Related Files

- [`lib/features/projects/data/datasources/projects_remote_datasource.dart`](lib/features/projects/data/datasources/projects_remote_datasource.dart) - API implementation
- [`lib/features/projects/data/models/project_model.dart`](lib/features/projects/data/models/project_model.dart) - Project data model
- [`lib/core/utils/app_toast.dart`](lib/core/utils/app_toast.dart) - Toast utility

## Notes

- The feature uses StatefulBuilder for the dialog to manage local loading state
- Project name and description are trimmed to remove leading/trailing whitespace
- The dialog automatically closes after successful project creation
- The projects bottom sheet is reopened to show the newly created project
- Error messages from the API are displayed to the user for debugging

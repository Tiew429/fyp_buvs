import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/student_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AddCandidatePage extends StatefulWidget {
  final VotingEventProvider votingEventProvider;
  final StudentProvider studentProvider;

  const AddCandidatePage({
    super.key, 
    required this.votingEventProvider,
    required this.studentProvider,
  });

  @override
  State<AddCandidatePage> createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  late final VotingEvent votingEvent;
  late TextEditingController _searchController;
  bool _isLoadingTransaction = false, _isLoadingStudent = false;
  late List<Student> _students;
  List<Student> _filteredStudents = [];
  final Set<String> _selectedStudentIds = {};
  Set<String> _existingCandidateIds = {};

  @override
  void initState() {
    super.initState();
    votingEvent = widget.votingEventProvider.selectedVotingEvent;
    _searchController = TextEditingController();
    _existingCandidateIds = _getExistingCandidateIds();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudent = true);
    
    try {
      // wait for students to be fetched
      await widget.studentProvider.fetchStudents();
      
      if (mounted) {
        setState(() {
          _students = widget.studentProvider.students;
          
          // filter students after they've been loaded
          _filteredStudents = _students.where((student) => 
            !_existingCandidateIds.contains(student.userID)
          ).toList();
          
          _isLoadingStudent = false;
        });
      }
    } catch (e) {
      // Handle any errors during loading
      if (mounted) {
        setState(() {
          _isLoadingStudent = false;
        });
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.errorLoadingStudents.getString(context)}: $e"
        );
      }
    }
  }

  // get existing candidate ids
  Set<String> _getExistingCandidateIds() {
    Set<String> existingIds = {};
    
    // add confirmed candidates
    for (var candidate in votingEvent.candidates) {
      existingIds.add(candidate.userID);
    }
    
    // add pending candidates
    for (var candidate in votingEvent.pendingCandidates) {
      existingIds.add(candidate.userID);
    }
    return existingIds;
  }

  // search students
  void _searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students.where((student) => 
          !_existingCandidateIds.contains(student.userID)
        ).toList();
      } else {
        _filteredStudents = _students.where((student) => 
          !_existingCandidateIds.contains(student.userID) &&
          (student.name.toLowerCase().contains(query.toLowerCase()) ||
           student.email.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }
    });
  }

  // toggle student selection status
  void _toggleStudentSelection(Student student) {
    if (!student.isEligibleForVoting) {
      SnackbarUtil.showSnackBar(
        context, 
        "${AppLocale.student.getString(context)} ${student.name} ${AppLocale.notEligibleForVoting.getString(context)}"
      );
      return;
    }
    
    setState(() {
      if (_selectedStudentIds.contains(student.userID)) {
        _selectedStudentIds.remove(student.userID);
      } else {
        _selectedStudentIds.add(student.userID);
      }
    });
  }

  // show confirmation dialog
  void _showConfirmationDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedStudentIds.isEmpty) {
      SnackbarUtil.showSnackBar(
        context, 
        AppLocale.pleaseSelectAtLeastOneStudent.getString(context)
      );
      return;
    }
    
    List<Student> selectedStudents = _students.where(
      (student) => _selectedStudentIds.contains(student.userID)
    ).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.confirmCandidates.getString(context)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: selectedStudents.length,
            itemBuilder: (context, index) {
              Student student = selectedStudents[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.email),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocale.cancel.getString(context),
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _addCandidates(selectedStudents);
            },
            child: Text(AppLocale.confirm.getString(context),
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // add candidates
  Future<void> _addCandidates(List<Student> students) async {
    if (votingEvent.startDate!.isBefore(DateTime.now()) && votingEvent.startTime!.isBefore(TimeOfDay.fromDateTime(DateTime.now()))) {
      SnackbarUtil.showSnackBar(
        context, 
        AppLocale.votingEventHasAlreadyStarted.getString(context)
      );
      return;
    } else if (votingEvent.endDate!.isBefore(DateTime.now()) && votingEvent.endTime!.isBefore(TimeOfDay.fromDateTime(DateTime.now()))) {
      SnackbarUtil.showSnackBar(
        context, 
        AppLocale.votingEventHasEnded.getString(context)
      );
      return;
    }

    setState(() {
      _isLoadingTransaction = true;
    });
    
    try {
      // create candidate objects
      List<Candidate> newCandidates = [];
      int startingId = _getExistingCandidateIds().length + 1;
      
      for (int i = 0; i < students.length; i++) {
        Student student = students[i];
        newCandidates.add(
          Candidate(
            candidateID: 'CAND_${startingId + i}',
            userID: student.userID,
            name: student.name,
            walletAddress: student.walletAddress,
            votingEventID: votingEvent.votingEventID,
            isConfirmed: true, // since it is added by admin or event creator
            avatarUrl: student.avatarUrl,
          )
        );
      }
      
      // in actual application, this should call the provider method to add candidates
      bool success = await widget.votingEventProvider.addCandidates(newCandidates);
      
      // update UI
      setState(() {
        _isLoadingTransaction = false;
        
        if (success) {
          _selectedStudentIds.clear();
        
          // update existing candidate ids
          for (var candidate in newCandidates) {
            _existingCandidateIds.add(candidate.userID);
          }
          
          // update filtered students list
          _filteredStudents = _students.where((student) => 
              !_existingCandidateIds.contains(student.userID)).toList();
        }
      });
      
      if (mounted) {
        if (!success) {
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.errorAddingCandidates.getString(context)
          );
        } else {
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.candidatesAddedSuccessfully.getString(context)
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingTransaction = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.errorAddingCandidates.getString(context)}: $e"
        );
      }
    }
  }

  // build student list item
  Widget _buildStudentItem(Student student) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _selectedStudentIds.contains(student.userID);
    bool isEligible = student.isEligibleForVoting;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          student.name,
          style: TextStyle(
            color: isEligible 
                ? colorScheme.onSurface 
                : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          student.email,
          style: TextStyle(
            color: isEligible 
                ? colorScheme.onSurface.withOpacity(0.7) 
                : colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: isEligible 
              ? (value) => _toggleStudentSelection(student)
              : null,
        ),
        onTap: () => _toggleStudentSelection(student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.addCandidate.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoadingStudent
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    AppLocale.loadingStudents.getString(context),
                    style: TextStyle(
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ScrollableResponsiveWidget(
                  phone: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // search bar
                      CustomSearchBox(
                        controller: _searchController,
                        onChanged: _searchStudents,
                        hintText: AppLocale.searchStudents.getString(context),
                      ),
                      const SizedBox(height: 16),
                      // student list
                      Flexible(
                        fit: FlexFit.loose,
                        child: _filteredStudents.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocale.noStudentsFound.getString(context),
                                  style: TextStyle(
                                    color: colorScheme.onTertiary,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _filteredStudents
                                      .map((student) => _buildStudentItem(student))
                                      .toList(),
                                ),
                              ),
                      ),
                      // confirm button
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: CustomAnimatedButton(
                          onPressed: _showConfirmationDialog,
                          text: AppLocale.addSelectedCandidates.getString(context),
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                  tablet: Container(),
                ),
                if (_isLoadingTransaction)
                  ProgressCircular(
                    isLoading: _isLoadingTransaction,
                    message: AppLocale.addingCandidates.getString(context),
                  )
              ],
            ),
    );
  }
}

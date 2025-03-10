import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AddCandidatePage extends StatefulWidget {
  final VotingEventViewModel votingEventViewModel;

  const AddCandidatePage({
    super.key, 
    required this.votingEventViewModel,
  });

  @override
  State<AddCandidatePage> createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  late final VotingEvent votingEvent;
  late TextEditingController _searchController;
  bool _isLoading = false;
  
  // 模拟学生数据，实际应用中应从数据库或API获取
  final List<Student> _allStudents = [
    Student(
      userID: 'student1',
      name: 'John Doe',
      email: 'john@example.com',
      role: UserRole.student,
      walletAddress: '',
      isEligibleForVoting: true,
    ),
    Student(
      userID: 'student2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: UserRole.student,
      walletAddress: '',
      isEligibleForVoting: true,
    ),
    Student(
      userID: 'student3',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      role: UserRole.student,
      walletAddress: '',
      isEligibleForVoting: false,
    ),
    Student(
      userID: 'student4',
      name: 'Alice Brown',
      email: 'alice@example.com',
      role: UserRole.student,
      walletAddress: '',
      isEligibleForVoting: true,
    ),
    Student(
      userID: 'student5',
      name: 'Charlie Wilson',
      email: 'charlie@example.com',
      role: UserRole.student,
      walletAddress: '',
      isEligibleForVoting: true,
    ),
  ];
  
  List<Student> _filteredStudents = [];
  Set<String> _selectedStudentIds = {};
  Set<String> _existingCandidateIds = {};

  @override
  void initState() {
    super.initState();
    votingEvent = widget.votingEventViewModel.selectedVotingEvent;
    _searchController = TextEditingController();
    
    // 初始化现有候选人ID集合
    _existingCandidateIds = _getExistingCandidateIds();
    
    // 初始化过滤后的学生列表
    _filteredStudents = _allStudents.where((student) => 
      !_existingCandidateIds.contains(student.userID)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 获取现有候选人ID
  Set<String> _getExistingCandidateIds() {
    Set<String> existingIds = {};
    
    // 添加已确认的候选人
    for (var candidate in votingEvent.candidates) {
      existingIds.add(candidate.userID);
    }
    
    // 添加待定的候选人
    for (var candidate in votingEvent.pendingCandidates) {
      existingIds.add(candidate.userID);
    }
    return existingIds;
  }

  // 搜索学生
  void _searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _allStudents.where((student) => 
          !_existingCandidateIds.contains(student.userID)
        ).toList();
      } else {
        _filteredStudents = _allStudents.where((student) => 
          !_existingCandidateIds.contains(student.userID) &&
          (student.name.toLowerCase().contains(query.toLowerCase()) ||
           student.email.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }
    });
  }

  // 切换学生选择状态
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

  // 显示确认对话框
  void _showConfirmationDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedStudentIds.isEmpty) {
      SnackbarUtil.showSnackBar(
        context, 
        AppLocale.pleaseSelectAtLeastOneStudent.getString(context)
      );
      return;
    }
    
    List<Student> selectedStudents = _allStudents.where(
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
            onPressed: () {
              Navigator.of(context).pop();
              _addCandidates(selectedStudents);
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

  // 添加候选人
  Future<void> _addCandidates(List<Student> students) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 创建候选人对象
      List<Candidate> newCandidates = students.map((student) => 
        Candidate(
          candidateID: 'CAND_${_getExistingCandidateIds().length + 1}',
          userID: student.userID,
          name: student.name,
          bio: '',
          walletAddress: student.walletAddress,
          votingEventID: votingEvent.votingEventID,
        )
      ).toList();
      
      // 在实际应用中，这里应该调用ViewModel的方法添加候选人
      await widget.votingEventViewModel.addCandidates(newCandidates);
      
      // 模拟延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 更新UI
      setState(() {
        _isLoading = false;
        _selectedStudentIds.clear();
        
        // 更新现有候选人ID集合
        for (var candidate in newCandidates) {
          _existingCandidateIds.add(candidate.userID);
        }
        
        // 更新过滤后的学生列表
        _filteredStudents = _allStudents.where((student) => 
          !_existingCandidateIds.contains(student.userID)
        ).toList();
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          AppLocale.candidatesAddedSuccessfully.getString(context)
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.errorAddingCandidates.getString(context)}: $e"
        );
      }
    }
  }

  // 构建学生列表项
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollableResponsiveWidget(
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 搜索栏
                  TextField(
                    controller: _searchController,
                    onChanged: _searchStudents,
                    decoration: InputDecoration(
                      hintText: AppLocale.searchStudents.getString(context),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 学生列表
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
                  
                  // 确认按钮
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
    );
  }
}
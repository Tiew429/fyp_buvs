mixin AppLocale {
  // roles
  static const String admin = 'admin';
  static const String staff = 'staff';
  static const String student = 'student';

  // voting event status
  static const String available = 'available';
  static const String deprecated = 'deprecated';

  // authentication
  static const String login = 'login';
  static const String register = 'register';
  static const String username = 'username';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirm password';
  static const String newPassword = 'new password';
  static const String confirmNewPassword = 'confirm new password';
  static const String forgotPassword = 'forgot password';
  static const String doesNotHaveAccount = 'doesn\'t have an account';
  static const String registerHere = 'register here';
  static const String otherLoginMethods = 'other login methods';
  static const String alreadyHaveAnAccount = 'already have an account';
  static const String loginHere = 'login here';
  static const String resetPassword = 'reset password';
  static const String requestVerificationCode = 'request verification code';
  static const String setNewPassword = 'set new password';
  static const String reset = 'reset';
  static const String passwordsDoNotMatch = 'passwords do not match';
  static const String verification = 'verification';
  static const String verificationCode = 'verification code';
  static const String verify = 'verify';
  static const String loggingIn = 'logging in...';
  static const String registering = 'registering...'; 
  static const String exportToReport = 'export to report';

  // home (dashboard, profile, settings)
  static const String home = 'home';

  // dashboard

  // profile
  static const String profile = 'profile';
  static const String editProfile = 'edit profile';
  static const String avatar = 'avatar';
  static const String changeAvatar = 'change avatar';
  static const String role = 'role';
  static const String walletAddress = 'wallet address';
  static const String bio = 'bio';
  static const String bioDescription = 'description of your profile';
  static const String haveNotConnectedWithCryptoWallet = 'haven\'t connect with cryptocurrency wallet';
  static const String connectWithCryptoWallet = 'connect with cryptocurrency wallet';
  static const String cryptocurrencyWalletAccountConnected = 'cryptocurrency wallet account connected';
  static const String setBiometricAuthentication = 'set biometric authentication';

  // settings
  static const String settings = 'settings';
  static const String themePreferences = 'theme preferences';
  static const String darkTheme = 'dark theme';
  static const String language = 'language';
  static const String savePreferences = 'save preferences';
  static const String logout = 'logout';

  // language
  static const String english = 'english';
  static const String malay = 'malay';
  static const String chinese = 'chinese';

  // notications
  static const String notifications = 'notifications';

  // votings
  static const String votingList = 'voting list';
  static const String createNew = 'create new';
  static const String createVotingEvent = 'create voting event';
  static const String title = 'title';
  static const String description = 'description';
  static const String startDate = 'start date';
  static const String endDate = 'end date';
  static const String startTime = 'start time';
  static const String endTime = 'end time';
  static const String pleaseSelectStartDateFirstBeforeYouSelectTheEndDate = 'please select start date first before you select the end date';
  static const String votingEventInformation = 'voting event information';
  static const String date = 'date';
  static const String time = 'time';
  static const String status = 'status';
  static const String candidateParticipated = 'candidate participated';
  static const String manageCandidate = 'manage candidate';
  static const String name = 'name';
  static const String editVotingEvent = 'edit voting event';
  static const String update = 'update';
  static const String votingEvent = 'voting event';
  static const String noVotingEventAvailable = 'no voting events available';
  static const String pendingVotingEvent = 'pending voting event';
  static const String noPendingStatusVotingEventAvailable = 'no pending status voting events available';
  static const String approve = 'approve';
  static const String reject = 'reject';
  static const String votingEventCreatedSuccessfully = 'voting event created successfully';
  static const String failedToCreateVotingEvent = 'failed to create voting event';
  static const String votingEventUpdatedSuccessfully = 'voting event updated successfully';
  static const String failedToUpdateVotingEvent = 'failed to update voting event';
  static const String delete = 'delete';
  static const String votingEventDeletedSuccessfully = 'voting event deleted successfully';
  static const String creatingVotingEvent = 'creating voting event...';
  static const String updatingVotingEvent = 'updating voting event...';
  static const String vote = 'vote';
  static const String statistics = 'statistics';
  static const String totalVotesCast = 'total votes cast';
  static const String percentageOfVotesCast = 'percentage of votes cast';
  static const String remainingVoters = 'remaining voters';
  static const String timeRemaining = 'time remaining';
  static const String results = 'results';
  static const String winner = 'winner';

  // student
  static const String notEligibleForVoting = 'not eligible for voting';
  static const String pleaseSelectAtLeastOneStudent = 'please select at least one student';
  static const String searchStudents = 'search students';
  static const String noStudentsFound = 'no students found';
  static const String errorLoadingStudents = 'error loading students';
  static const String loadingStudents = 'loading students...';

  // candidate
  static const String candidate = 'candidate';
  static const String confirmCandidates = 'confirm candidates';
  static const String confirmedCandidate = 'confirmed candidate';
  static const String pendingCandidate = 'pending candidate';
  static const String noConfirmedCandidateAvailable = 'no confirmed candidate available';
  static const String noPendingCandidateAvailable = 'no pending candidate available';
  static const String noCandidateFound = 'no candidate found';
  static const String votesReceived = 'votes received';
  static const String confirmed = 'confirmed';
  static const String rejected = 'rejected';
  static const String pending = 'pending';
  static const String errorConfirmingCandidate = 'error confirming candidate';
  static const String errorRejectingCandidate = 'error rejecting candidate';
  static const String addCandidate = 'add candidate';
  static const String candidatesAddedSuccessfully = 'candidates added successfully';
  static const String errorAddingCandidates = 'error adding candidates';
  static const String addSelectedCandidates = 'add selected candidates';
  static const String addingCandidates = 'adding candidates...';

  // validator_util
  static const String dontLeaveBlank = 'please don\'t leave this field blank';
  static const String emailCantBeBlank = 'email cannot be blank';
  static const String enterValidEmail = 'please enter valid email address';
  static const String passwordCantBeBlank = 'password cannot be blank';
  static const String passwordMustAtLeast6Char = 'password must be at least 6 characters long';

  // auth_service
  static const String userNotFound = 'user is not found';

  // dialog
  static const String save = 'save';
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String confirmSave = 'confirm save';
  static const String noChanges = 'no changes';

  // others
  static const String pleaseConnectYourWallet = 'please connect your wallet';
  static const String close = 'close';

  // english-en
  static const Map<String, dynamic> en = {
    // roles
    admin: 'Administrator',
    staff: 'Staff',
    student: 'Student',

    // voting event status
    available: 'Available',
    deprecated: 'Deprecated',

    // authentication
    login: 'Login',
    register: 'Register',
    username: 'Username',
    email: 'Email',
    password: 'Password',
    confirmPassword: 'Confirm Password',
    newPassword: 'New Password',
    confirmNewPassword: 'Confirm New Password',
    forgotPassword: 'Forgot password',
    doesNotHaveAccount: 'Doesn\'t have an account',
    registerHere: 'Register here',
    otherLoginMethods: 'Other login methods',
    alreadyHaveAnAccount: 'Already have an account',
    loginHere: 'Login here',
    resetPassword: 'Reset Password',
    requestVerificationCode: 'Request Verification Code',
    setNewPassword: 'Set New Password',
    reset: 'Reset',
    passwordsDoNotMatch: 'Passwords do not match',
    verification: 'Verification',
    verificationCode: 'Verification Code',
    verify: 'Verify',
    loggingIn: 'Logging in...', 
    registering: 'Registering...',
    exportToReport: 'Export to Report',

    // home
    home: 'Home',

    // settings
    settings: 'Settings',
    themePreferences: 'Theme Preferences',
    darkTheme: 'Dark Theme',
    language: 'Language',
    savePreferences: 'Save Preferences',
    logout: 'Logout',

    // language
    english: 'English',
    malay: 'Malay',
    chinese: 'Chinese',

    // profile
    profile: 'Profile',
    editProfile: 'Edit Profile',
    avatar: 'Avatar',
    changeAvatar: 'Change Avatar',
    role: 'Role',
    walletAddress: 'Wallet Address',
    bio: 'Bio',
    bioDescription: 'Description of your profile',
    haveNotConnectedWithCryptoWallet: 'Haven\'t connect with cryptocurrency wallet',
    connectWithCryptoWallet: 'Connect with cryptocurrency wallet',
    cryptocurrencyWalletAccountConnected: 'Cryptocurrency wallet account connected',
    setBiometricAuthentication: 'Set biometric authentication',
    
    // notifications
    notifications: 'Notifications',

    // voting
    votingList: 'Voting List',
    createNew: 'Create New',
    createVotingEvent: 'Create Voting Event',
    title: 'Title',
    description: 'Description',
    startDate: 'Start Date',
    endDate: 'End Date',
    startTime: 'Start Time',
    endTime: 'End Time',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: 'Please select start date first before you select the end date',
    votingEventInformation: 'Voting Event Information',
    date: 'Date',
    time: 'Time',
    status: 'Status',
    candidateParticipated: 'Candidate Participated',
    manageCandidate: 'Manage Candidate',
    name: 'Name',
    editVotingEvent: 'Edit Voting Event',
    update: 'Update',
    votingEvent: 'Voting Event',
    noVotingEventAvailable: 'No voting events available',
    pendingVotingEvent: 'Pending Voting Event',
    noPendingStatusVotingEventAvailable: 'No pending status voting event available',
    approve: 'Approve',
    reject: 'Reject',
    votingEventCreatedSuccessfully: 'Voting event created successfully',
    failedToCreateVotingEvent: 'Failed to create voting event',
    votingEventUpdatedSuccessfully: 'Voting event updated successfully',
    failedToUpdateVotingEvent: 'Failed to update voting event',
    delete: 'Delete',
    votingEventDeletedSuccessfully: 'Voting event deleted successfully',
    creatingVotingEvent: 'Creating voting event...',
    updatingVotingEvent: 'Updating voting event...',
    vote: 'Vote',
    statistics: 'Statistics',
    totalVotesCast: 'Total Votes Cast',
    percentageOfVotesCast: 'Percentage of Votes Cast',
    remainingVoters: 'Remaining Voters',
    timeRemaining: 'Time Remaining',
    results: 'Results',
    winner: 'Winner',

    // student
    notEligibleForVoting: 'Not eligible for voting',
    pleaseSelectAtLeastOneStudent: 'Please select at least one student',
    searchStudents: 'Search students',
    noStudentsFound: 'No students found',
    errorLoadingStudents: 'Error loading students',
    loadingStudents: 'Loading students...',

    // candidate
    candidate: 'Candidate',
    confirmCandidates: 'Confirm Candidates',
    confirmedCandidate: 'Confirmed Candidate',
    pendingCandidate: 'Pending Candidate',
    noConfirmedCandidateAvailable: 'No confirmed candidate available',
    noPendingCandidateAvailable: 'No pending candidate available',
    noCandidateFound: 'No candidate found',
    votesReceived: 'Votes Received',
    confirmed: 'Confirmed',
    pending: 'Pending',
    rejected: 'Rejected',
    errorConfirmingCandidate: 'Error confirming candidate',
    errorRejectingCandidate: 'Error rejecting candidate',
    addCandidate: 'Add Candidate',
    candidatesAddedSuccessfully: 'Candidates added successfully',
    errorAddingCandidates: 'Error adding candidates',
    addSelectedCandidates: 'Add Selected Candidates',
    addingCandidates: 'Adding candidates...',

    // validator_util
    dontLeaveBlank: 'Please don\'t leave this field blank',
    emailCantBeBlank: 'Email cannot be blank',
    enterValidEmail: 'Please enter valid email address',
    passwordCantBeBlank: 'Password cannot be blank',
    passwordMustAtLeast6Char: 'Password must be at least 6 characters long',

    // auth_service
    userNotFound: 'User not found',

    // dialog
    save: 'Save',
    cancel: 'Cancel',
    confirm: 'Confirm',
    confirmSave: 'Confirm Save',
    noChanges: 'No Changes',

    // others
    pleaseConnectYourWallet: 'Please connect your wallet',
    close: 'Close',
  };

  // malay-ms
  static const Map<String, dynamic> ms = {
    // roles
    admin: 'Pentadbir',
    staff: 'Kakitangan',
    student: 'Pelajar',

    // voting event status
    available: 'Tersedia',
    deprecated: 'Ditamatkan',

    // authentication
    login: 'Log Masuk',
    register: 'Log Keluar',
    username: 'Nama Pengguna',
    email: 'Emel',
    password: 'Kata Laluan',
    confirmPassword: 'Sahkan Kata Laluan',
    newPassword: 'Kata Laluan Baharu',
    confirmNewPassword: 'Mengesahkan Kata Laluan Baharu',
    forgotPassword: 'Lupa kata laluan',
    doesNotHaveAccount: 'Tiada akaun',
    registerHere: 'Daftar di sini',
    otherLoginMethods: 'Kaedah log masuk lain',
    alreadyHaveAnAccount: 'Sudah ada akaun',
    loginHere: 'Log masuk sini',
    resetPassword: 'Set Semula Kata Laluan',
    requestVerificationCode: 'Minta Kod Pengesahan',
    setNewPassword: 'Tetapkan Kata Laluan Baharu',
    reset: 'Set Semula',
    passwordsDoNotMatch: 'Kata laluan tidak padan',
    verification: 'Pengesahan',
    verificationCode: 'Kod Pengesahan',
    verify: 'Sahkan',
    loggingIn: 'Log masuk...',
    registering: 'Mendaftar...',
    exportToReport: 'Eksport ke Laporan',

    // home
    home: 'Home',

    // settings
    settings: 'Tetapan',
    themePreferences: 'Keutamaan Tema',
    darkTheme: 'Tema Gelap',
    language: 'Bahasa',
    savePreferences: 'Simpan Keutamaan',
    logout: 'Log Keluar',

    // language
    english: 'Inggeris',
    malay: 'Melayu',
    chinese: 'Cina',

    // profile
    profile: 'Profil',
    editProfile: 'Edit Profil',
    avatar: 'Avatar',
    changeAvatar: 'Tukar Avatar',
    role: 'Peranan',
    walletAddress: 'Alamat Wallet',
    bio: 'Bio',
    bioDescription: 'Deskripsi profil anda',
    haveNotConnectedWithCryptoWallet: 'Belum terhubung dengan kripto wallet',
    connectWithCryptoWallet: 'Hubungkan dengan kripto wallet',
    cryptocurrencyWalletAccountConnected: 'Akun kripto wallet terhubung',
    setBiometricAuthentication: 'Set autentikasi biometrik',

    // notifications
    notifications: 'Notifikasi',

    // voting
    votingList: 'Senarai Undian',
    createNew: 'Cipta Baharu',
    createVotingEvent: 'Cipta Undian',
    title: 'Judul',
    description: 'Deskripsi',
    startDate: 'Tarikh Mulai',
    endDate: 'Tarikh Tamat',
    startTime: 'Waktu Mulai',
    endTime: 'Waktu Tamat',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: 'Sila pilih tarikh mulai terlebih dahulu sebelum memilih tarikh tamat',
    votingEventInformation: 'Maklumat Acara Pengundian',
    date: 'Hari',
    time: 'Masa',
    status: 'Status',
    candidateParticipated: 'Calon Menyertai',
    manageCandidate: 'Uruskan Calon',
    name: 'Nama',
    editVotingEvent: 'Edit Acara Pengundian',
    update: 'Kemas Kini',
    votingEvent: 'Acara Pengundian',
    noVotingEventAvailable: 'Tiada acara undian tersedia',
    pendingVotingEvent: 'Acara Pengundian Belum Selesai',
    noPendingStatusVotingEventAvailable: 'Tiada acara undian status belum selesai tersedia',
    approve: 'Luluskan',
    reject: 'Menolak',
    votingEventCreatedSuccessfully: 'Acara pengundian berjaya dicipta',
    failedToCreateVotingEvent: 'Gagal membuat acara pengundian',
    votingEventUpdatedSuccessfully: 'Acara pengundian berjaya dikemas kini',
    failedToUpdateVotingEvent: 'Gagal mengemas kini acara pengundian',
    delete: 'Hapus',
    votingEventDeletedSuccessfully: 'Acara pengundian berjaya dihapus',
    creatingVotingEvent: 'Sedang membuat acara pengundian...',
    updatingVotingEvent: 'Sedang mengemas kini acara pengundian...',
    vote: 'Undi',
    statistics: 'Statistik',
    totalVotesCast: 'Jumlah Undian Dibuat',
    percentageOfVotesCast: 'Peratusan Undian Dibuat',
    remainingVoters: 'Jumlah Pengguna Tidak Undi',
    timeRemaining: 'Masa Tinggal',
    results: 'Hasil',
    winner: 'Pemenang',

    // student
    notEligibleForVoting: 'Tidak layak untuk pengundian', 
    pleaseSelectAtLeastOneStudent: 'Sila pilih sekurang-kurangnya satu pelajar',
    searchStudents: 'Cari pelajar',
    noStudentsFound: 'Tiada pelajar ditemui',
    errorLoadingStudents: 'Gagal memuatkan pelajar',
    loadingStudents: 'Memuatkan pelajar...',

    // candidate
    candidate: 'Calon',
    confirmCandidates: 'Konfirmasi Calon',
    confirmedCandidate: 'Calon Diluluskan',
    pendingCandidate: 'Calon Belum Diluluskan',
    noConfirmedCandidateAvailable: 'Tiada calon yang diluluskan tersedia',
    noPendingCandidateAvailable: 'Tiada calon belum diluluskan tersedia',
    noCandidateFound: 'Tiada calon ditemui',
    votesReceived: 'Jumlah Undian',
    confirmed: 'Diluluskan',
    rejected: 'Menolak',
    pending: 'Belum Diluluskan',
    errorConfirmingCandidate: 'Kesalahan mengkonfirmasi calon',
    errorRejectingCandidate: 'Kesalahan menolak calon',
    addCandidate: 'Tambah Calon',
    candidatesAddedSuccessfully: 'Calon berjaya ditambahkan',
    errorAddingCandidates: 'Kesalahan menambahkan calon',
    addSelectedCandidates: 'Tambah Calon yang Dipilih',
    addingCandidates: 'Menambahkan calon...',

    // validator_util
    dontLeaveBlank: 'Medan ini tidak boleh kosong',
    emailCantBeBlank: 'Emel tidak boleh kosong',
    enterValidEmail: 'Sila masukkan emel yang sah',
    passwordCantBeBlank: 'Kata laluan tidak boleh kosong',
    passwordMustAtLeast6Char: 'Kata laluan mestilah sekurang-kurangnya 6 aksara',

    // auth_service
    userNotFound: 'Pengguna tidak ditemui',

    // dialog
    save: 'Simpan',
    cancel: 'Batal',
    confirm: 'Konfirmasi',
    confirmSave: 'Konfirmasi Simpan',
    noChanges: 'Tidak Ada Perubahan',

    // others
    pleaseConnectYourWallet: 'Sila hubungkan kripto wallet anda',
    close: 'Tutup',
  };

  // chinese-zh
  static const Map<String, dynamic> zh = {
    // roles
    admin: '管理员',
    staff: '职员',
    student: '学生',

    // voting event status
    available: '可用',
    deprecated: '已弃用',

    // authentication
    login: '登录',
    register: '注册',
    username: '用户名',
    email: '电子邮件',
    password: '密码',
    confirmPassword: '确认密码',
    newPassword: '新密码',
    confirmNewPassword: '确认新密码',
    forgotPassword: '忘记密码',
    doesNotHaveAccount: '没有账号',
    registerHere: '在此注册',
    otherLoginMethods: '其他登录方式',
    alreadyHaveAnAccount: '已有账号',
    loginHere: '在此登录',
    resetPassword: '重置密码',
    requestVerificationCode: '获取验证码',
    setNewPassword: '设置新密码',
    reset: '重置',
    passwordsDoNotMatch: '密码不匹配',
    verification: '验证',
    verificationCode: '验证码',
    verify: '验证',
    loggingIn: '登录中...',
    registering: '注册中...',
    exportToReport: '导出到报告',
    
    // home
    home: '主页',

    // settings
    settings: '设置',
    themePreferences: '主题偏好',
    darkTheme: '深色主题',
    language: '语言',
    savePreferences: '保存偏好',
    logout: '登出',

    // language
    english: '英语',
    malay: '马来语',
    chinese: '中文',

    // profile
    profile: '个人资料',
    editProfile: '编辑个人资料',
    avatar: '头像',
    changeAvatar: '更改头像',
    role: '角色',
    walletAddress: '钱包地址',
    bio: '个人简介',
    bioDescription: '个人简介',
    haveNotConnectedWithCryptoWallet: '尚未连接到加密货币钱包',
    connectWithCryptoWallet: '连接到加密货币钱包',
    cryptocurrencyWalletAccountConnected: '加密货币钱包账户已连接',
    setBiometricAuthentication: '设置生物识别认证',

    // notifications
    notifications: '通知',

    // voting
    votingList: '投票列表',
    createNew: '新建',
    createVotingEvent: '创建投票事件',
    title: '标题',
    description: '描述',
    startDate: '开始日期',
    endDate: '结束日期',
    startTime: '开始时间',
    endTime: '结束时间',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: '请先选择开始日期，然后再选择结束日期',
    votingEventInformation: '投票活动信息',
    date: '日期',
    time: '时间',
    status: '状态',
    candidateParticipated: '候选人参与',
    manageCandidate: '管理候选人',
    name: '名字',
    editVotingEvent: '编辑投票活动',
    update: '更新',
    votingEvent: '投票活动',
    noVotingEventAvailable: '没有可用的投票活动',
    pendingVotingEvent: '待定投票活动',
    noPendingStatusVotingEventAvailable: '没有可用的待定状态投票活动',
    approve: '批准',
    reject: '拒绝',
    votingEventCreatedSuccessfully: '投票活动已创建成功',
    failedToCreateVotingEvent: '创建投票活动失败',
    votingEventUpdatedSuccessfully: '投票活动已更新成功',
    failedToUpdateVotingEvent: '更新投票活动失败',
    delete: '删除',
    votingEventDeletedSuccessfully: '投票活动已删除成功',
    creatingVotingEvent: '正在创建投票活动...',
    updatingVotingEvent: '正在更新投票活动...',
    vote: '投票',
    statistics: '统计',
    totalVotesCast: '总投票数',
    percentageOfVotesCast: '投票百分比',
    remainingVoters: '剩余投票者',
    timeRemaining: '剩余时间',
    results: '结果',
    winner: '获胜者',

    // student
    notEligibleForVoting: '不符合投票资格',
    pleaseSelectAtLeastOneStudent: '请至少选择一个学生',
    searchStudents: '搜索学生',
    noStudentsFound: '没有找到学生',
    errorLoadingStudents: '加载学生失败',
    loadingStudents: '加载学生...',

    // candidate
    candidate: '候选人',
    confirmCandidates: '确认候选人',
    confirmedCandidate: '已确认候选人',
    pendingCandidate: '待确认候选人',
    noConfirmedCandidateAvailable: '没有可用的已确认候选人',
    noPendingCandidateAvailable: '没有可用的待确认候选人',
    noCandidateFound: '没有找到候选人',
    votesReceived: '票数',
    confirmed: '已确认',
    rejected: '已拒绝',
    pending: '待确认',
    errorConfirmingCandidate: '确认候选人失败',
    errorRejectingCandidate: '拒绝候选人失败',
    addCandidate: '添加候选人',
    candidatesAddedSuccessfully: '候选人已添加成功',
    errorAddingCandidates: '添加候选人失败',
    addSelectedCandidates: '添加选定候选人',
    addingCandidates: '添加候选人...',

    // validator_util
    dontLeaveBlank: '此字段不能为空',
    emailCantBeBlank: '电子邮件不能为空',
    enterValidEmail: '请输入有效的电子邮件',
    passwordCantBeBlank: '密码不能为空',
    passwordMustAtLeast6Char: '密码必须至少6个字符',

    // auth_service
    userNotFound: '未找到用户',

    // dialog
    save: '保存',
    cancel: '取消',
    confirm: '确认',
    confirmSave: '确认保存',
    noChanges: '没有更改',

    // others
    pleaseConnectYourWallet: '请连接您的钱包',
    close: '关闭',
  };
}

import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final User _user;

  const EditProfilePage({
    super.key,
    required User user,
  }) :_user = user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _walletAddressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _walletAddressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget._user.email;
    _usernameController.text = widget._user.name;
    _walletAddressController.text = widget._user.walletAddress;
    _bioController.text = widget._user.bio;
  }

  void _edit() async {
    final updatedUser = User(
      userID: widget._user.userID,
      email: _emailController.text,
      name: _usernameController.text,
      walletAddress: _walletAddressController.text,
      bio: _bioController.text,
      role: widget._user.role,
      isVerified: widget._user.isVerified,
    );
    final userViewModel = Provider.of<UserProvider>(context, listen: false);
    await userViewModel.updateUser(updatedUser);
    if (context.mounted) {
      NavigationHelper.navigateBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.editProfile.getString(context)),
        leading: IconButton(
          onPressed: () {
            NavigationHelper.navigateBack(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      backgroundColor: colorScheme.tertiary,
      body: ScrollableWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(AppLocale.avatar.getString(context)),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: screenSize.shortestSide * 0.15,
                    child: Image.asset('assets/images/fox.png'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomConfirmButton(
                    text: AppLocale.changeAvatar.getString(context),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(AppLocale.email.getString(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      readOnly: true,
                      controller: _emailController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.user),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(AppLocale.username.getString(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      readOnly: true,
                      controller: _usernameController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wallet),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(AppLocale.walletAddress.getString(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      readOnly: true,
                      controller: _walletAddressController.text.isEmpty
                          ? TextEditingController(
                              text: AppLocale.haveNotConnectedWithCryptoWallet
                                  .getString(context),
                            )
                          : _walletAddressController,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.description),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(AppLocale.bio.getString(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _bioController,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Spacer(),
                  CustomConfirmButton(
                    text: AppLocale.save.getString(context),
                    onPressed: () => _edit(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

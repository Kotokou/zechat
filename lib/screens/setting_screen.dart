import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zechat/configs/constants/app_colors.dart';
import 'package:zechat/configs/constants/app_constants.dart';
import 'package:zechat/configs/constants/firestore_constants.dart';
import 'package:zechat/configs/widgets/loading_view.dart';
import 'package:zechat/models/user_chat.dart';
import 'package:zechat/providers/setting_provider.dart';
import '../main.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor,
        ),
        title: const Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: AppColors.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SettingsScreenState(),
    );
  }
}

class SettingsScreenState extends StatefulWidget {
  const SettingsScreenState({super.key});


  @override
  State<SettingsScreenState> createState() => _SettingsScreenStateState();
}

class _SettingsScreenStateState extends State<SettingsScreenState> {
  TextEditingController? controllerNickName;
  TextEditingController? controllerAboutMe;

   TextEditingController _controller = TextEditingController();

  String dialCodeDigits = "+00";

  String id = "";
  String nickName = "";
  String aboutMe = "";
  String photoUrl = "";
  String phoneNumber = "";

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  readLocal() {
    setState(() {
      id = settingProvider.getPref("id") ?? "";
      nickName = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "";
      phoneNumber =
          settingProvider.getPref(FirestoreConstants.phoneNumber) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
    });

    controllerNickName = TextEditingController(text: nickName);
    controllerAboutMe = TextEditingController(text: aboutMe);
    _controller = TextEditingController(text: phoneNumber);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker
        .getImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
      return null;
    });

    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask =
        settingProvider.uploadTask(avatarImageFile!, fileName);
    try {
      TaskSnapshot taskSnapshot = await uploadTask;
      photoUrl = await taskSnapshot.ref.getDownloadURL();

      UserChat updateInfo = UserChat(
        id: id,
        photoURL: photoUrl,
        nickname: nickName,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber,
      );

      settingProvider
          .updateDataFirestore(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((data) async {
        await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void handleUpdateData() {
    aboutMeFocusNode.unfocus();
    nickNameFocusNode.unfocus();

    setState(() {
      isLoading = true;

      if(dialCodeDigits != "+00" && _controller.text != "") {
        phoneNumber = dialCodeDigits + _controller.text.toString();
      }
    });

    UserChat updateInfo = UserChat(
      id: id,
      photoURL: photoUrl,
      nickname: nickName,
      aboutMe: aboutMe,
      phoneNumber: phoneNumber,
    );

    settingProvider
        .updateDataFirestore(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {
      await settingProvider.setPref(FirestoreConstants.nickname, nickName);
      await settingProvider.setPref(FirestoreConstants.aboutMe, aboutMe);
      await settingProvider.setPref(
          FirestoreConstants.phoneNumber, phoneNumber);
      await settingProvider.setPref(FirestoreConstants.nickname, photoUrl);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Update Success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: avatarImageFile == null
                      ? photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(
                                photoUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, object, stackTrace) {
                                  return const Icon(
                                    Icons.account_circle_outlined,
                                    size: 90,
                                    color: AppColors.greyColor,
                                  );
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.account_circle_outlined,
                              size: 90,
                              color: AppColors.greyColor,
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.file(
                            avatarImageFile!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    child: const Text(
                      "Name",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: AppColors.primaryColor),
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          hintText: "Écrit ton blaaz négro",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: AppColors.greyColor),
                        ),
                        controller: controllerNickName,
                        onChanged: (value) {
                          setState(() {
                            nickName = value;
                          });
                        },
                        focusNode: nickNameFocusNode,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    child: const Text(
                      "About Me",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: AppColors.primaryColor),
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          hintText: "Parle nous de toi",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: AppColors.greyColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          setState(() {
                            aboutMe = value;
                          });
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    child: const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 30, bottom: 5),
                    child: SizedBox(
                      width: 400,
                      height: 60,
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            dialCodeDigits = country.dialCode!;
                          });
                        },
                        showCountryOnly: false,
                        initialSelection: "IT",
                        showOnlyCountryWhenClosed: false,
                        favorite: const ["+1", "US", "+92", "PAK"],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: AppColors.primaryColor),
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          hintText: phoneNumber,
                          contentPadding: const EdgeInsets.all(5),
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefix: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              dialCodeDigits,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        controller: _controller,
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 50, bottom: 50),
                      child: TextButton(
                        onPressed: handleUpdateData,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.primaryColor),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            )),
                        child: const Text(
                          "Update Now",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          child: isLoading ? const LoadingView() : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

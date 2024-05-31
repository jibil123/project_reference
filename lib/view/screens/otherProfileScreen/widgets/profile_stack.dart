import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joylink/model/bloc/followBloc/follow_bloc.dart';
import 'package:joylink/model/model/search_model.dart';
import 'package:joylink/utils/colors.dart';
import 'package:joylink/view/screens/profileScreen/widgets/follow_text_widget.dart';
import 'package:joylink/viewModel/firebase/follow_unfollow/follow_unfollow.dart';

class OtherProfileStack extends StatelessWidget {
  OtherProfileStack({super.key, required this.userModel});
  final UserModel userModel;
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FollowBloc(UserService()),
      child: SizedBox(
        height: 400,
        child: Stack(
          children: [
            userModel.coverImage.isNotEmpty
                ? Image.network(
                    userModel.coverImage,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Image(
                    height: 250,
                    width: double.infinity,
                    image: AssetImage('assets/images/cover_photo.jpg'),
                    fit: BoxFit.cover,
                  ),
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_sharp,
                    color: AppColors.blackColor,
                  )),
            ),
            Positioned(
              top: 200,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteColor, width: 5),
                ),
                child: userModel.imageUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(userModel.imageUrl),
                      )
                    : const CircleAvatar(
                        radius: 80,
                        backgroundColor: AppColors.primaryColor,
                        child: ClipOval(
                          child: Image(
                            image: AssetImage('assets/images/pngegg.png'),
                          ),
                        ),
                      ),
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
                stream: firestore
                    .collection('user details')
                    .doc(userModel.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  final follow = (data?['followers'] as List?) ?? [];
                  final following = (data?['following'] as List?) ?? [];

                  return Positioned(
                    top: 255, // Adjusted top position
                    right: 10, // Adjusted right position
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        followFunction('Following ',following.length),
                        const SizedBox(height: 10),
                        followFunction('Followers ',follow.length),
                        BlocBuilder<FollowBloc, FollowState>(
                          builder: (context, state) { 
                            return ElevatedButton(
                              onPressed: () {
                                if (follow
                                    .contains(firebaseAuth.currentUser!.uid)) {
                                  context.read<FollowBloc>().add(
                                      UnfollowUserEvent(
                                          firebaseAuth.currentUser!.uid, userModel.id));
                                } else {
                                  context.read<FollowBloc>().add(
                                      FollowUserEvent(
                                          currentUserId:
                                              firebaseAuth.currentUser!.uid,
                                          targetUserId: userModel.id));
                                }
                              },
                              child: Text(
                                  follow.contains(firebaseAuth.currentUser!.uid)
                                      ? 'Unfollow'
                                      : 'Follow'),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

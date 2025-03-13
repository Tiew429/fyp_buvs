import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

enum CandidateStatus {
  none,
  pending,
  confirmed
}

class CandidateBox extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final CandidateStatus status;
  final bool showAvatar;
  
  const CandidateBox({
    super.key,
    required this.candidate,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.status = CandidateStatus.none,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actualTextColor = textColor ?? colorScheme.onPrimary;
    
    // Get candidate data directly from the Candidate object
    final name = candidate.name;
    final bio = candidate.bio;
    final walletAddress = candidate.userID;
    
    return GestureDetector(
      onTap: onTap,
      child: CenteredContainer(
        containerPaddingVertical: 10.0,
        child: Stack(
          children: [
            // Main content
            Row(
              children: [
                if (showAvatar)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: actualTextColor,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: colorScheme.primary.withOpacity(0.2),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: TextStyle(
                            color: actualTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocale.name.getString(context)}: $name",
                          style: TextStyle(
                            color: actualTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${AppLocale.bio.getString(context)}: $bio",
                          style: TextStyle(
                            color: actualTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (walletAddress.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "ID: ${_truncateWalletAddress(walletAddress)}",
                            style: TextStyle(
                              color: actualTextColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Status badge
            if (status != CandidateStatus.none)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status, colorScheme),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    _getStatusText(status, context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(CandidateStatus status, ColorScheme colorScheme) {
    switch (status) {
      case CandidateStatus.confirmed:
        return Colors.green;
      case CandidateStatus.pending:
        return Colors.orange;
      case CandidateStatus.none:
        return Colors.transparent;
    }
  }
  
  String _getStatusText(CandidateStatus status, BuildContext context) {
    switch (status) {
      case CandidateStatus.confirmed:
        return AppLocale.confirm.getString(context);
      case CandidateStatus.pending:
        return AppLocale.pending.getString(context);
      case CandidateStatus.none:
        return "";
    }
  }
  
  String _truncateWalletAddress(String address) {
    if (address.length <= 10) return address;
    return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
  }
}

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features/voice_assistant/presentation/pages/voice_assistant_page.dart';
import 'features/voice_assistant/presentation/widgets/voice_floating_button.dart';

void main() => runApp(const ProviderScope(child: HealthVaultApp()));

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> dialNumber(BuildContext context, String number) async {
  final uri = Uri(scheme: 'tel', path: number);
  if (!await launchUrl(uri)) {
    if (context.mounted) showAppMessage(context, 'Calling is not available on this device.');
  }
}

class AppColors {
  static const primary = Color(0xFF0D7C8A);
  static const primaryLight = Color(0xFFE9F5F6);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const slate900 = Color(0xFF0F172A);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate100 = Color(0xFFF1F5F9);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF0EA5E9);
  static const purple = Color(0xFF8B5CF6);
}

class HealthVaultApp extends StatelessWidget {
  const HealthVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthVault',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
        ),
        fontFamily: 'Arial',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900),
          titleMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900),
          bodyMedium: TextStyle(color: AppColors.slate600),
        ),
      ),
      home: const AppShell(),
    );
  }
}

enum AppPage { home, timeline, upload, family, profile, records, emergency, medications, memberDetail, addMember, assistant }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage page = AppPage.home;

  void go(AppPage next) => setState(() => page = next);

  @override
  Widget build(BuildContext context) {
    final showHeader = !{AppPage.records, AppPage.emergency, AppPage.medications, AppPage.memberDetail, AppPage.addMember, AppPage.assistant}.contains(page);
    final showNav = !{AppPage.memberDetail, AppPage.addMember, AppPage.assistant}.contains(page);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  if (showHeader) AppHeader(onNavigate: go),
                  Expanded(child: _content()),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: page == AppPage.home
          ? VoiceFloatingButton(onTap: () => go(AppPage.assistant))
          : null,
      bottomNavigationBar: showNav ? BottomNav(current: _navPage(page), onTap: go) : null,
    );
  }

  AppPage _navPage(AppPage value) {
    if ({AppPage.records, AppPage.emergency, AppPage.medications}.contains(value)) return AppPage.home;
    return value;
  }

  Widget _content() {
    switch (page) {
      case AppPage.home:
        return HomePage(onNavigate: go);
      case AppPage.timeline:
        return const TimelinePage();
      case AppPage.upload:
        return const UploadPage();
      case AppPage.family:
        return FamilyPage(onNavigate: go);
      case AppPage.profile:
        return const ProfilePage();
      case AppPage.records:
        return RecordsVaultPage(onBack: () => go(AppPage.home));
      case AppPage.emergency:
        return EmergencyPage(onBack: () => go(AppPage.home));
      case AppPage.medications:
        return MedicationsPage(onBack: () => go(AppPage.home));
      case AppPage.memberDetail:
        return MemberDetailPage(onBack: () => go(AppPage.family));
      case AppPage.addMember:
        return AddMemberPage(onBack: () => go(AppPage.family));
      case AppPage.assistant:
        return VoiceAssistantPage(onBack: () => go(AppPage.home), onNavigate: (destination) {
          final target = {
            'emergency': AppPage.emergency,
            'medications': AppPage.medications,
            'records': AppPage.records,
            'upload': AppPage.upload,
            'family': AppPage.family,
            'timeline': AppPage.timeline,
          }[destination];
          if (target != null) go(target);
        });
    }
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFEFF3F7))),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text('S', style: TextStyle(color: AppColors.primary.withOpacity(.9), fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Good morning,', style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text('Sarah', style: TextStyle(fontSize: 19, color: AppColors.slate900, fontWeight: FontWeight.w800)),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.slate500),
                  ],
                ),
              ],
            ),
          ),
          IconPill(icon: Icons.mic_none, onTap: () => onNavigate(AppPage.assistant)),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconPill(icon: Icons.notifications_none, onTap: () => _showNotifications(context)),
              Positioned(right: 9, top: 9, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white)))),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => const SafeArea(child: Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        SizedBox(height: 16),
        IconListRow(icon: Icons.medication_outlined, color: AppColors.primary, title: 'Evening medicines', subtitle: 'Metformin and Atorvastatin are due at 8:00 PM'),
        IconListRow(icon: Icons.monitor_heart_outlined, color: AppColors.warning, title: 'Blood pressure check', subtitle: 'Robert has a reading due today'),
      ]),
    )));
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.current, required this.onTap});

  final AppPage current;
  final ValueChanged<AppPage> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppPage.home, Icons.home_outlined, 'Home'),
      (AppPage.timeline, Icons.monitor_heart_outlined, 'Timeline'),
      (AppPage.upload, Icons.add_circle, 'Upload'),
      (AppPage.family, Icons.groups_outlined, 'Family'),
      (AppPage.profile, Icons.person_outline, 'Profile'),
    ];
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            height: 76,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((item) {
                final selected = item.$1 == current;
                final primary = item.$1 == AppPage.upload;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTap(item.$1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(primary ? 8 : 6),
                          decoration: BoxDecoration(
                            color: primary ? AppColors.primary : selected ? AppColors.primaryLight : Colors.transparent,
                            shape: primary ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: primary ? null : BorderRadius.circular(14),
                            boxShadow: primary ? const [BoxShadow(color: Color(0x330D7C8A), blurRadius: 16, offset: Offset(0, 7))] : null,
                          ),
                          child: Icon(item.$2, size: primary ? 30 : 23, color: primary ? Colors.white : selected ? AppColors.primary : AppColors.slate500),
                        ),
                        const SizedBox(height: 2),
                        Text(item.$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? AppColors.primary : AppColors.slate500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 22),
      children: [
        FamilyQuickSwitch(onNavigate: onNavigate),
        QuickActions(onNavigate: onNavigate),
        EmergencyCard(onNavigate: onNavigate),
        const HealthSummaryCard(),
        MedicationReminder(onNavigate: onNavigate),
        SectionHeader(title: 'Recent Reports', action: 'View Vault', onAction: () => onNavigate(AppPage.records)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(onTap: () => onNavigate(AppPage.records), borderRadius: BorderRadius.circular(22), child: CardBox(
            child: Row(
              children: [
                Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(10)), child: const Text('PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.slate500))),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete Blood Count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.slate900)),
                      SizedBox(height: 3),
                      Text('City Lab • Oct 12, 2023', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                    ],
                  ),
                ),
                const StatusChip(label: 'Normal', color: AppColors.success),
              ],
            ),
          )),
        ),
      ],
    );
  }
}

class FamilyQuickSwitch extends StatelessWidget {
  const FamilyQuickSwitch({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final members = [
      ('Sarah', 'Self', false),
      ('David', 'Spouse', false),
      ('Robert', 'Father', true),
      ('Emma', 'Daughter', false),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: members.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == members.length) {
            return AddCircleAvatar(
              onTap: () => onNavigate(AppPage.addMember),
            );
          }

          final member = members[index];

          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => onNavigate(
              member.$2 == 'Self'
                  ? AppPage.profile
                  : AppPage.memberDetail,
            ),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: member.$2 == 'Self'
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.slate100,
                          child: Text(
                            member.$1[0],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ),
                      if (member.$3)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: member.$2 == 'Self'
                          ? AppColors.primary
                          : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddCircleAvatar extends StatelessWidget {
  const AddCircleAvatar({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(30), child: const Column(
      children: [
        CircleAvatar(radius: 29, backgroundColor: AppColors.slate100, child: Icon(Icons.add, color: AppColors.slate500, size: 28)),
        SizedBox(height: 6),
        Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate500)),
      ],
    ));
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Upload Report', Icons.description_outlined, AppColors.primary, () => onNavigate(AppPage.upload)),
      ('Consultation', Icons.medical_services_outlined, AppColors.purple, () {}),
      ('Find Records', Icons.find_in_page_outlined, AppColors.info, () => onNavigate(AppPage.records)),
      ('Share Data', Icons.ios_share_outlined, AppColors.warning, () {}),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: a.$4,
              child: Column(
                children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: a.$3.withOpacity(.10), borderRadius: BorderRadius.circular(18)), child: Icon(a.$2, color: a.$3)),
                  const SizedBox(height: 8),
                  Text(a.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate600)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x33EF4444), blurRadius: 22, offset: Offset(0, 10))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EMERGENCY CARD', style: TextStyle(color: Color(0xFFFFCDD2), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .8)),
                      SizedBox(height: 4),
                      Text('Sarah Jenkins', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.white24, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  color: Colors.white,
                  onPressed: () => onNavigate(AppPage.emergency),
                  icon: const Icon(Icons.qr_code_2),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: InfoPair(label: 'Blood Group', value: 'O Positive', inverse: true)),
                Expanded(child: InfoPair(label: 'Allergies', value: 'Penicillin, Peanuts', inverse: true, small: true)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () => dialNumber(context, '+15559876543'), icon: const Icon(Icons.phone, size: 18), label: const Text('Call ICE'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0x88B91C1C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () => onNavigate(AppPage.emergency), child: const Text('View Details'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Blood Pressure', '120/80', 'mmHg', Icons.favorite_outline, AppColors.success, 'Today', Icons.remove),
      ('Blood Sugar', '105', 'mg/dL', Icons.water_drop_outlined, AppColors.warning, 'Yesterday', Icons.trending_up),
      ('Heart Rate', '72', 'bpm', Icons.monitor_heart_outlined, AppColors.success, 'Today', Icons.remove),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const SectionHeader(title: 'Health Vitals', action: 'View All'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (context, c) {
              final half = (c.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: metrics.asMap().entries.map((entry) {
                  final full = entry.key == 0;
                  final m = entry.value;
                  return SizedBox(
                    width: full ? c.maxWidth : half,
                    child: CardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TintIcon(icon: m.$4, color: m.$5), Icon(m.$7, size: 16, color: m.$5)]),
                          const SizedBox(height: 12),
                          Text(m.$1, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(m.$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.slate900)), const SizedBox(width: 4), Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(m.$3, style: const TextStyle(fontSize: 12, color: AppColors.slate500)))]),
                          const SizedBox(height: 4),
                          Text(m.$6, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MedicationReminder extends StatelessWidget {
  const MedicationReminder({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final meds = [
      ('Metformin', '500mg', '08:00 AM', true),
      ('Atorvastatin', '10mg', '09:00 PM', false),
    ];
    return Column(
      children: [
        SectionHeader(title: "Today's Medicines", action: 'View All', onAction: () => onNavigate(AppPage.medications)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: CardBox(
            padding: EdgeInsets.zero,
            child: Column(
              children: meds.map((m) => MedicineRow(name: m.$1, dose: m.$2, detail: m.$3, taken: m.$4)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final members = [
      FamilyMember('Sarah Jenkins', 'Self', 34, 'O+', false, null, 'Today', true),
      FamilyMember('David Jenkins', 'Spouse', 36, 'A+', false, null, '2 days ago', false),
      FamilyMember('Robert Jenkins', 'Father', 68, 'O-', true, 'BP check due today', 'Yesterday', false),
      FamilyMember('Emma Jenkins', 'Daughter', 8, 'A+', false, null, '1 week ago', false),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        PageIntro(icon: Icons.groups_outlined, title: 'Family Profiles', subtitle: 'Manage health records and track vitals for your entire family in one place.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...members.map((m) => FamilyMemberCard(member: m, onTap: () => onNavigate(AppPage.memberDetail))),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onNavigate(AppPage.addMember),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.slate300, width: 1.4), borderRadius: BorderRadius.circular(24)),
                  child: const Column(
                    children: [
                      CircleAvatar(radius: 25, backgroundColor: AppColors.slate100, child: Icon(Icons.person_add_alt, color: AppColors.slate500)),
                      SizedBox(height: 10),
                      Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate600)),
                      SizedBox(height: 3),
                      Text('Link an existing account or create a new profile', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FamilyMember {
  FamilyMember(this.name, this.relation, this.age, this.bloodGroup, this.hasAlert, this.alertMessage, this.lastUpdated, this.primary);
  final String name;
  final String relation;
  final int age;
  final String bloodGroup;
  final bool hasAlert;
  final String? alertMessage;
  final String lastUpdated;
  final bool primary;
}

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({super.key, required this.member, required this.onTap});
  final FamilyMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: CardBox(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(radius: 33, backgroundColor: member.primary ? AppColors.primary : AppColors.slate300, child: CircleAvatar(radius: 30, backgroundColor: AppColors.slate100, child: Text(member.name[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.slate600)))),
                        if (member.primary) const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 10, backgroundColor: AppColors.primary, child: Icon(Icons.shield_outlined, color: Colors.white, size: 12))),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Expanded(child: Text(member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900))), const Icon(Icons.chevron_right, color: AppColors.slate500)]),
                          Text('${member.relation} • ${member.age} yrs • ${member.bloodGroup}', style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          member.hasAlert
                              ? StatusPill(icon: Icons.error_outline, label: member.alertMessage ?? 'Needs attention', color: AppColors.danger)
                              : StatusPill(icon: Icons.monitor_heart_outlined, label: 'Updated ${member.lastUpdated}', color: AppColors.success, neutral: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('View Records', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w800)), Text('Manage Profile', style: TextStyle(fontSize: 12, color: AppColors.slate600, fontWeight: FontWeight.w800))]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final events = [
      TimelineEvent('consultation', 'Oct 15', 'Cardiology Follow-up', 'Routine checkup for blood pressure management.', 'Dr. Robert Chen', 'City Heart Center', null),
      TimelineEvent('report', 'Oct 12', 'Lipid Profile & CBC', 'Cholesterol levels slightly elevated. CBC normal.', null, 'Quest Diagnostics', 'Reviewed'),
      TimelineEvent('prescription', 'Oct 12', 'New Medication Added', 'Atorvastatin 10mg prescribed for cholesterol.', 'Dr. Robert Chen', null, null),
      TimelineEvent('vaccination', 'Sep 05', 'Annual Flu Shot', 'Influenza vaccine administered.', null, 'Walgreens Pharmacy', null),
      TimelineEvent('procedure', 'Jul 22', 'Echocardiogram', 'Normal left ventricular systolic function.', null, 'City Heart Center', 'Normal'),
    ];
    final filters = ['All', 'Consults', 'Reports', 'Meds'];
    return Column(
      children: [
        StickyHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [Expanded(child: Text('Health Timeline', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.slate900))), IconPill(icon: Icons.calendar_month_outlined)]),
              const SizedBox(height: 12),
              const SearchField(hint: 'Search events, doctors, or reports...'),
              const SizedBox(height: 12),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: filters.map((f) => FilterChipButton(label: f, selected: filter == f, dark: true, onTap: () => setState(() => filter = f))).toList())),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
            children: [
              const Align(alignment: Alignment.centerLeft, child: StatusChip(label: '2023', color: AppColors.slate600, muted: true)),
              const SizedBox(height: 14),
              ...events.asMap().entries.map((e) => TimelineEventCard(event: e.value, last: e.key == events.length - 1)),
              const Center(child: Padding(padding: EdgeInsets.only(top: 8), child: CircleAvatar(radius: 4, backgroundColor: AppColors.slate300))),
            ],
          ),
        ),
      ],
    );
  }
}

class TimelineEvent {
  TimelineEvent(this.type, this.date, this.title, this.subtitle, this.doctor, this.facility, this.status);
  final String type;
  final String date;
  final String title;
  final String subtitle;
  final String? doctor;
  final String? facility;
  final String? status;
}

class TimelineEventCard extends StatelessWidget {
  const TimelineEventCard({super.key, required this.event, required this.last});
  final TimelineEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final iconData = _eventIcon(event.type);
    final color = _eventColor(event.type);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 52, child: Text(event.date, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w800))),
        Column(
          children: [
            CircleAvatar(radius: 18, backgroundColor: color.withOpacity(.12), child: Icon(iconData, size: 18, color: color)),
            if (!last) Container(width: 2, height: 104, color: const Color(0xFFE2E8F0)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Expanded(child: Text(event.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.slate900))), if (event.status != null) StatusChip(label: event.status!, color: AppColors.success)]),
                  const SizedBox(height: 6),
                  Text(event.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.slate600, height: 1.35)),
                  if (event.doctor != null || event.facility != null) ...[
                    const SizedBox(height: 10),
                    Text([event.doctor, event.facility].whereType<String>().join(' • '), style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

enum UploadState { select, uploading, processing, results }

class _UploadPageState extends State<UploadPage> {
  UploadState state = UploadState.select;
  int progress = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startUpload() {
    timer?.cancel();
    setState(() {
      state = UploadState.uploading;
      progress = 0;
    });
    timer = Timer.periodic(const Duration(milliseconds: 180), (t) {
      if (progress >= 100) {
        t.cancel();
        setState(() => state = UploadState.processing);
        Future.delayed(const Duration(milliseconds: 1700), () {
          if (mounted) setState(() => state = UploadState.results);
        });
      } else {
        setState(() => progress += 10);
      }
    });
  }

  Future<void> pickCamera() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null && mounted) startUpload();
  }

  Future<void> pickGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null && mounted) startUpload();
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
);
    if (result != null && mounted) startUpload();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case UploadState.select:
        return _select();
      case UploadState.uploading:
        return CenterStage(
          child: Column(
            children: [
              SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress / 100, strokeWidth: 8, color: AppColors.primary, backgroundColor: AppColors.slate100), Text('$progress%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.slate900))])),
              const SizedBox(height: 24),
              const Text('Uploading Document...', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.slate900)),
              const SizedBox(height: 8),
              const Text('Please keep the app open while we upload your file securely.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500)),
            ],
          ),
        );
      case UploadState.processing:
        return const CenterStage(
          child: Column(
            children: [
              CircleAvatar(radius: 52, backgroundColor: AppColors.primaryLight, child: Icon(Icons.description_outlined, color: AppColors.primary, size: 36)),
              SizedBox(height: 24),
              Text('Extracting Data...', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.slate900)),
              SizedBox(height: 8),
              Text('Our AI is reading your report to extract vital health metrics automatically.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500)),
              SizedBox(height: 28),
              CheckLine(text: 'Document recognized as Lab Report'),
              CheckLine(text: 'Patient details matched'),
              CheckLine(text: 'Reading test results...', loading: true),
            ],
          ),
        );
      case UploadState.results:
        return _results();
    }
  }

  Widget _select() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
      children: [
        const CircleAvatar(radius: 35, backgroundColor: AppColors.primaryLight, child: Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 36)),
        const SizedBox(height: 16),
        const Text('Upload Medical Record', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.slate900)),
        const SizedBox(height: 8),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Upload your lab reports, prescriptions, or bills. Our AI will automatically extract the details.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500, height: 1.35))),
        const SizedBox(height: 30),
        UploadOption(icon: Icons.photo_camera_outlined, title: 'Take a Photo', subtitle: 'Use camera to scan document', onTap: pickCamera),
        UploadOption(icon: Icons.image_outlined, title: 'Upload from Gallery', subtitle: 'Select images from your phone', onTap: pickGallery),
        UploadOption(icon: Icons.picture_as_pdf_outlined, title: 'Upload PDF', subtitle: 'Browse files on your device', onTap: pickPdf),
      ],
    );
  }

  Widget _results() {
    final data = [
      ('Hemoglobin', '13.5', 'g/dL', '12.0 - 15.5', false),
      ('Fasting Blood Sugar', '110', 'mg/dL', '70 - 100', true),
      ('Total Cholesterol', '185', 'mg/dL', '< 200', false),
    ];
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.success.withOpacity(.10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Extraction Successful', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)), SizedBox(height: 4), Text('Please verify the extracted details below before saving to your vault.', style: TextStyle(fontSize: 12, color: AppColors.slate600))])),
              IconButton(onPressed: () => setState(() => state = UploadState.select), icon: const Icon(Icons.close, color: AppColors.slate500)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [SectionLabel('Document Details'), InfoPair(label: 'Document Type', value: 'Lab Report - Blood Work'), SizedBox(height: 12), Row(children: [Expanded(child: InfoPair(label: 'Date', value: 'Oct 24, 2023')), Expanded(child: InfoPair(label: 'Patient Name', value: 'Sarah Jenkins'))]) ])),
              const SizedBox(height: 22),
              const SectionLabel('Extracted Metrics'),
              const SizedBox(height: 10),
              ...data.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Expanded(child: Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900))), if (d.$5) const StatusPill(icon: Icons.error_outline, label: 'High', color: AppColors.warning)]),
                          const SizedBox(height: 8),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(d.$2, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: d.$5 ? AppColors.warning : AppColors.slate900)), const SizedBox(width: 4), Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(d.$3, style: const TextStyle(fontSize: 12, color: AppColors.slate500)))]),
                          const SizedBox(height: 4),
                          Text('Ref Range: ${d.$4}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: () {
                showAppMessage(context, 'Report saved securely to your Health Vault.');
                setState(() => state = UploadState.select);
              }, child: const Text('Save to Health Vault', style: TextStyle(fontWeight: FontWeight.w900)))),
            ],
          ),
        ),
      ],
    );
  }
}

class RecordsVaultPage extends StatefulWidget {
  const RecordsVaultPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<RecordsVaultPage> createState() => _RecordsVaultPageState();
}

class _RecordsVaultPageState extends State<RecordsVaultPage> {
  String category = 'All';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Lab', 'Prescription', 'Radiology', 'Vaccine', 'Notes'];
    final records = [
      Record('Complete Blood Count', 'Lab', 'Oct 12, 2023', 'City Lab Diagnostics', ['Routine', 'Normal'], Icons.monitor_heart_outlined, AppColors.info),
      Record('Cardiology Prescription', 'Prescription', 'Oct 10, 2023', 'Dr. Robert Chen', ['Active'], Icons.description_outlined, AppColors.primary),
      Record('Chest X-Ray', 'Radiology', 'Sep 28, 2023', 'Metro Imaging Center', ['Clear'], Icons.image_outlined, AppColors.purple),
      Record('Annual Flu Vaccine', 'Vaccine', 'Sep 05, 2023', 'Walgreens Pharmacy', ['Completed'], Icons.shield_outlined, AppColors.success),
      Record('Lipid Panel', 'Lab', 'Jun 15, 2023', 'Quest Diagnostics', ['Borderline'], Icons.monitor_heart_outlined, AppColors.warning),
    ];
    final filtered = records.where((record) {
      final matchesCategory = category == 'All' || record.category == category;
      final haystack = '${record.title} ${record.facility} ${record.tags.join(' ')}'.toLowerCase();
      return matchesCategory && haystack.contains(query.toLowerCase().trim());
    }).toList();
    return Column(
      children: [
        SubPageHeader(title: 'Health Vault', onBack: widget.onBack, bottom: Column(children: [SearchField(hint: 'Search records, doctors, or tags...', onChanged: (value) => setState(() => query = value)), const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: categories.map((c) => FilterChipButton(label: c == 'All' ? 'All Records' : c, selected: c == category, onTap: () => setState(() => category = c))).toList()))])),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [Expanded(child: Text('${filtered.length} Records Found', style: const TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.w800))), TextButton(onPressed: () => showAppMessage(context, 'Multi-select mode enabled.'), child: const Text('Select Multiple'))]),
              const SizedBox(height: 12),
              ...filtered.map((record) => RecordCard(record: record)),
            ],
          ),
        ),
      ],
    );
  }
}

class Record {
  Record(this.title, this.category, this.date, this.facility, this.tags, this.icon, this.color);
  final String title;
  final String category;
  final String date;
  final String facility;
  final List<String> tags;
  final IconData icon;
  final Color color;
}

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});
  final Record record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardBox(
        child: Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TintIcon(icon: record.icon, color: record.color),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(record.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.slate900)), const SizedBox(height: 4), Text('${record.facility} • ${record.date}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)), const SizedBox(height: 9), Wrap(spacing: 6, children: record.tags.map((t) => StatusChip(label: t, color: AppColors.slate600, muted: true)).toList())])),
              PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: AppColors.slate500, size: 20), onSelected: (value) => showAppMessage(context, '$value: ${record.title}'), itemBuilder: (_) => const [PopupMenuItem(value: 'View details', child: Text('View details')), PopupMenuItem(value: 'Rename', child: Text('Rename')), PopupMenuItem(value: 'Delete', child: Text('Delete'))]),
            ]),
            const Divider(height: 26, color: Color(0xFFF1F5F9)),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [SmallAction(icon: Icons.ios_share_outlined, label: 'Share', onTap: () => showAppMessage(context, 'Secure share link created for ${record.title}.')), const SizedBox(width: 8), SmallAction(icon: Icons.download_outlined, label: 'Download', primary: true, onTap: () => showAppMessage(context, '${record.title} downloaded.'))]),
          ],
        ),
      ),
    );
  }
}

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final List<bool> taken = [true, true, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubPageHeader(title: 'Medications', onBack: widget.onBack, trailing: IconPill(icon: Icons.add, color: AppColors.primary, bg: AppColors.primaryLight, onTap: () => _addMedication(context))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CardBox(child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Weekly Adherence', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)), SizedBox(height: 4), Text("You're doing great this week!", style: TextStyle(fontSize: 12, color: AppColors.slate500))])), SizedBox(width: 66, height: 66, child: Stack(alignment: Alignment.center, children: const [CircularProgressIndicator(value: .85, strokeWidth: 6, color: AppColors.success, backgroundColor: AppColors.slate100), Text('85%', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900))]))])),
              const SizedBox(height: 16),
              AlertBox(color: AppColors.warning, icon: Icons.error_outline, title: 'Refill Reminder', text: 'Atorvastatin is running low. You have 5 days of medication left.', button: 'Order Refill', onPressed: () => showAppMessage(context, 'Refill request sent to Walgreens Pharmacy.')),
              const SizedBox(height: 24),
              Row(children: const [Expanded(child: Text("Today's Schedule", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.slate900))), Icon(Icons.schedule, size: 16, color: AppColors.slate500), SizedBox(width: 4), Text('Oct 24', style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 16),
              const SectionLabel('Morning (08:00 AM)'),
              const SizedBox(height: 8),
              CardBox(padding: EdgeInsets.zero, child: Column(children: [MedicineRow(name: 'Metformin', dose: '500mg', detail: 'After food', taken: taken[0], onTap: () => _toggle(0)), MedicineRow(name: 'Lisinopril', dose: '10mg', detail: 'Before food', taken: taken[1], onTap: () => _toggle(1))])),
              const SizedBox(height: 18),
              const SectionLabel('Evening (08:00 PM)'),
              const SizedBox(height: 8),
              CardBox(padding: EdgeInsets.zero, child: Column(children: [MedicineRow(name: 'Metformin', dose: '500mg', detail: 'After food', taken: taken[2], onTap: () => _toggle(2)), MedicineRow(name: 'Atorvastatin', dose: '20mg', detail: 'After food', taken: taken[3], onTap: () => _toggle(3))])),
            ],
          ),
        ),
      ],
    );
  }

  void _toggle(int index) {
    setState(() => taken[index] = !taken[index]);
    showAppMessage(context, taken[index] ? 'Medicine marked as taken.' : 'Medicine returned to the schedule.');
  }

  void _addMedication(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Add medication'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Medication name')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () {
        if (controller.text.trim().isEmpty) return;
        Navigator.pop(dialogContext);
        showAppMessage(context, '${controller.text.trim()} added to your medication list.');
      }, child: const Text('Add'))],
    ));
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubPageHeader(title: 'Emergency Info', onBack: onBack, trailing: const StatusPill(icon: Icons.error_outline, label: 'ICE', color: AppColors.danger)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x33EF4444), blurRadius: 24, offset: Offset(0, 12))]),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PATIENT NAME', style: TextStyle(color: Color(0xFFFFCDD2), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: .8)),
                  SizedBox(height: 4),
                  Text('Sarah Jenkins', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
                  SizedBox(height: 24),
                  Row(children: [Expanded(child: InfoPair(label: 'Blood Group', value: 'O Positive', inverse: true)), Expanded(child: InfoPair(label: 'Allergies', value: 'Penicillin\nPeanuts (Severe)', inverse: true, small: true))]),
                  SizedBox(height: 22),
                  InfoPair(label: 'Medical Conditions', value: 'Type 2 Diabetes, Mild Hypertension', inverse: true, small: true),
                ]),
              ),
              const SizedBox(height: 16),
              CardBox(child: Row(children: const [QrBlock(), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency Access QR', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)), SizedBox(height: 6), Text('First responders can scan this to view your complete medical history temporarily.', style: TextStyle(fontSize: 12, color: AppColors.slate500, height: 1.35)), SizedBox(height: 10), Text('Show Full QR', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w900))]))])),
              const SizedBox(height: 20),
              const SectionLabel('Emergency Contacts'),
              const SizedBox(height: 10),
              const CardBox(padding: EdgeInsets.zero, child: Column(children: [ContactRow(name: 'David Jenkins', detail: 'Spouse • +1 (555) 987-6543'), ContactRow(name: 'Dr. Robert Chen', detail: 'Primary Care • +1 (555) 123-4567')])),
              const SizedBox(height: 20),
              const SectionLabel('Current Critical Medications'),
              const SizedBox(height: 10),
              CardBox(child: Column(children: const [KeyValueRow(left: 'Metformin', right: '500mg • Twice Daily'), SizedBox(height: 14), KeyValueRow(left: 'Lisinopril', right: '10mg • Once Daily')])),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      ('Account & Security', [(Icons.shield_outlined, 'Privacy & Security', 'Face ID enabled'), (Icons.ios_share_outlined, 'Data Sharing Controls', '2 Active Links')]),
      ('Preferences', [(Icons.notifications_none, 'Notifications', 'All On'), (Icons.language, 'Language', 'English (US)')]),
      ('Data Management', [(Icons.download_outlined, 'Export Health Data', '')]),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
          color: Colors.white,
          child: Column(children: const [
            Stack(children: [CircleAvatar(radius: 50, backgroundColor: AppColors.primaryLight, child: Text('S', style: TextStyle(fontSize: 38, color: AppColors.primary, fontWeight: FontWeight.w900))), Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Icon(Icons.settings, size: 16, color: Colors.white)))]),
            SizedBox(height: 14),
            Text('Sarah Jenkins', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.slate900)),
            SizedBox(height: 5),
            Text('sarah.j@example.com • +1 (555) 123-4567', style: TextStyle(fontSize: 13, color: AppColors.slate500)),
            SizedBox(height: 12),
            StatusPill(icon: Icons.shield_outlined, label: 'Account Verified', color: AppColors.success),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...sections.map((section) => Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SectionLabel(section.$1),
                      const SizedBox(height: 10),
                      CardBox(padding: EdgeInsets.zero, child: Column(children: section.$2.map((item) => SettingsRow(icon: item.$1, label: item.$2, value: item.$3)).toList())),
                    ]),
                  )),
              InkWell(onTap: () => showAppMessage(context, 'Support request opened. We will contact you shortly.'), borderRadius: BorderRadius.circular(22), child: const CardBox(child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.help_outline, size: 18, color: AppColors.slate600), SizedBox(width: 8), Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate600))])))),
              const SizedBox(height: 12),
              InkWell(onTap: () => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Log out?'), content: const Text('You will need to sign in again to access your health vault.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(dialogContext); showAppMessage(context, 'Logged out demo completed.'); }, child: const Text('Log out'))])), borderRadius: BorderRadius.circular(18), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFEE2E2))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, size: 18, color: AppColors.danger), SizedBox(width: 8), Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger))]))),
              const SizedBox(height: 28),
              const Text('HealthVault v1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ],
    );
  }
}

class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubPageHeader(title: 'Profile Details', onBack: onBack, trailing: const Icon(Icons.more_vert, color: AppColors.slate600)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                child: Column(children: const [
                  CircleAvatar(radius: 50, backgroundColor: AppColors.slate100, child: Text('R', style: TextStyle(fontSize: 38, color: AppColors.slate600, fontWeight: FontWeight.w900))),
                  SizedBox(height: 14),
                  Text('Robert Jenkins', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                  SizedBox(height: 5),
                  Text('Father • 68 yrs • O-', style: TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.w700)),
                  SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [SmallAction(icon: Icons.description_outlined, label: 'Records', primary: true), SizedBox(width: 10), SmallAction(icon: Icons.monitor_heart_outlined, label: 'Timeline')]),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const AlertBox(color: AppColors.danger, icon: Icons.error_outline, title: 'BP Check Due', text: "Please record today's blood pressure reading."),
                  const SizedBox(height: 22),
                  const SectionLabel('Allergies'),
                  const SizedBox(height: 10),
                  CardBox(child: Wrap(spacing: 8, runSpacing: 8, children: const [StatusChip(label: 'Penicillin', color: AppColors.danger), StatusChip(label: 'Sulfa Drugs', color: AppColors.danger)])),
                  const SizedBox(height: 22),
                  const SectionLabel('Chronic Conditions'),
                  const SizedBox(height: 10),
                  const CardBox(padding: EdgeInsets.zero, child: Column(children: [IconListRow(icon: Icons.monitor_heart_outlined, color: AppColors.warning, title: 'Type 2 Diabetes'), IconListRow(icon: Icons.monitor_heart_outlined, color: AppColors.warning, title: 'Hypertension')])),
                  const SizedBox(height: 22),
                  Row(children: const [Expanded(child: SectionLabel('Current Medications')), Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w800))]),
                  const SizedBox(height: 10),
                  const CardBox(padding: EdgeInsets.zero, child: Column(children: [IconListRow(icon: Icons.medication_outlined, color: AppColors.primary, title: 'Metformin', subtitle: '500mg • Twice daily'), IconListRow(icon: Icons.medication_outlined, color: AppColors.primary, title: 'Telmisartan', subtitle: '40mg • Morning')])),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  bool submitting = false;
  bool success = false;
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void submit() {
    if (nameController.text.trim().isEmpty) {
      showAppMessage(context, 'Enter the family member’s full name.');
      return;
    }
    setState(() => submitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        submitting = false;
        success = true;
      });
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) widget.onBack();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (success) {
      return const CenterStage(child: Column(children: [CircleAvatar(radius: 42, backgroundColor: Color(0xFFEAFBF4), child: Icon(Icons.check_circle_outline, color: AppColors.success, size: 46)), SizedBox(height: 18), Text('Member Added', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.slate900)), SizedBox(height: 8), Text('Profile created successfully.', style: TextStyle(color: AppColors.slate500))]));
    }
    return Column(
      children: [
        SubPageHeader(title: 'Add Family Member', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: InkWell(onTap: () async {
                final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (photo != null && mounted) showAppMessage(context, 'Profile photo selected.');
              }, customBorder: const CircleBorder(), child: const CircleAvatar(radius: 50, backgroundColor: AppColors.slate100, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_alt, color: AppColors.slate500), SizedBox(height: 2), Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.w700))])))),
              const SizedBox(height: 28),
              AppTextField(label: 'Full Name', hint: 'e.g. John Doe', controller: nameController),
              const SizedBox(height: 16),
              const Row(children: [Expanded(child: AppSelect(label: 'Relation', value: 'Select...')), SizedBox(width: 12), Expanded(child: AppSelect(label: 'Blood Group', value: 'Select...'))]),
              const SizedBox(height: 16),
              const Row(children: [Expanded(child: AppTextField(label: 'Date of Birth', hint: 'mm/dd/yyyy')), SizedBox(width: 12), Expanded(child: AppSelect(label: 'Gender', value: 'Select...'))]),
              const SizedBox(height: 34),
              SizedBox(width: double.infinity, height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: submitting ? null : submit, child: submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.w900)))),
            ],
          ),
        ),
      ],
    );
  }
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 4))]),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.slate900))),
          if (action != null) InkWell(onTap: onAction, child: Text(action!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w900, letterSpacing: .7));
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.muted = false});
  final String label;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: muted ? AppColors.slate100 : color.withOpacity(.10), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: muted ? AppColors.slate600 : color)),
      );
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.icon, required this.label, required this.color, this.neutral = false});
  final IconData icon;
  final String label;
  final Color color;
  final bool neutral;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: neutral ? const Color(0xFFF8FAFC) : color.withOpacity(.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: neutral ? const Color(0xFFF1F5F9) : color.withOpacity(.14))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 14), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: neutral ? AppColors.slate500 : color))]),
      );
}

class TintIcon extends StatelessWidget {
  const TintIcon({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20));
}

class IconPill extends StatelessWidget {
  const IconPill({super.key, required this.icon, this.color = AppColors.slate600, this.bg = const Color(0xFFF8FAFC), this.onTap});
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(color: bg, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(9), child: Icon(icon, color: color, size: 20))));
}

class InfoPair extends StatelessWidget {
  const InfoPair({super.key, required this.label, required this.value, this.inverse = false, this.small = false});
  final String label;
  final String value;
  final bool inverse;
  final bool small;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: inverse ? const Color(0xFFFFCDD2) : AppColors.slate500, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: small ? 14 : 18, height: 1.25, color: inverse ? Colors.white : AppColors.slate900, fontWeight: FontWeight.w900))]);
}

class MedicineRow extends StatelessWidget {
  const MedicineRow({super.key, required this.name, required this.dose, required this.detail, required this.taken, this.onTap});
  final String name;
  final String dose;
  final String detail;
  final bool taken;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap ?? () => showAppMessage(context, taken ? '$name marked as not taken.' : '$name marked as taken.'), child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC)))),
        child: Row(
          children: [
            TintIcon(icon: Icons.medication_outlined, color: taken ? AppColors.success : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontWeight: FontWeight.w800, color: taken ? AppColors.slate500 : AppColors.slate900, decoration: taken ? TextDecoration.lineThrough : null)), const SizedBox(height: 4), Text('$dose • $detail', style: const TextStyle(fontSize: 12, color: AppColors.slate500))])),
            Icon(taken ? Icons.check_circle_outline : Icons.radio_button_unchecked, color: taken ? AppColors.success : AppColors.slate300, size: 30),
          ],
        ),
      ));
}

class PageIntro extends StatelessWidget {
  const PageIntro({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.slate900)))]), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.slate500, height: 1.35))]),
      );
}

class StickyHeader extends StatelessWidget {
  const StickyHeader({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), decoration: BoxDecoration(color: Colors.white.withOpacity(.96), border: const Border(bottom: BorderSide(color: Color(0xFFEFF3F7)))), child: child);
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, this.onChanged});
  final String hint;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          suffixIcon: const Icon(Icons.tune, color: Color(0xFF94A3B8), size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
        ),
      );
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({super.key, required this.label, required this.selected, required this.onTap, this.dark = false});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => onTap(),
          label: Text(label),
          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.slate600),
          selectedColor: dark ? AppColors.slate900 : AppColors.primary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE2E8F0))),
          showCheckmark: false,
        ),
      );
}

class SubPageHeader extends StatelessWidget {
  const SubPageHeader({super.key, required this.title, required this.onBack, this.trailing, this.bottom});
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEFF3F7)))),
        child: Column(
          children: [
            Row(children: [IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: AppColors.slate600)), Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.slate900))), trailing ?? const SizedBox(width: 40)]),
            if (bottom != null) Padding(padding: const EdgeInsets.fromLTRB(8, 10, 0, 0), child: bottom!),
          ],
        ),
      );
}

class UploadOption extends StatelessWidget {
  const UploadOption({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: CardBox(child: Row(children: [TintIcon(icon: icon, color: AppColors.primary), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.slate500))])), const Icon(Icons.chevron_right, color: AppColors.slate500)])),
        ),
      );
}

class CenterStage extends StatelessWidget {
  const CenterStage({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: child));
}

class CheckLine extends StatelessWidget {
  const CheckLine({super.key, required this.text, this.loading = false});
  final String text;
  final bool loading;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.slate600)) : const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18), const SizedBox(width: 10), Text(text, style: TextStyle(fontSize: 13, color: loading ? AppColors.slate500 : AppColors.slate600))]),
      );
}

class AlertBox extends StatelessWidget {
  const AlertBox({super.key, required this.color, required this.icon, required this.title, required this.text, this.button, this.onPressed});
  final Color color;
  final IconData icon;
  final String title;
  final String text;
  final String? button;
  final VoidCallback? onPressed;
 @override
Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: color == AppColors.danger
                        ? AppColors.danger
                        : AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: color == AppColors.danger
                        ? AppColors.danger.withOpacity(.8)
                        : AppColors.slate600,
                  ),
                ),
                if (button != null) ...[
                  const SizedBox(height: 10),
                  InkWell(onTap: onPressed ?? () => showAppMessage(context, '$button request submitted.'), borderRadius: BorderRadius.circular(10), child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      button!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
}

class SmallAction extends StatelessWidget {
  const SmallAction({super.key, required this.icon, required this.label, this.primary = false, this.onTap});
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap ?? () => showAppMessage(context, '$label action completed.'), borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: primary ? AppColors.primaryLight : AppColors.slate100, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: primary ? AppColors.primary : AppColors.slate600), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, color: primary ? AppColors.primary : AppColors.slate600, fontWeight: FontWeight.w900))])));
}

class QrBlock extends StatelessWidget {
  const QrBlock({super.key});
  @override
  Widget build(BuildContext context) => Container(width: 82, height: 82, decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.slate300, width: 1.5)), child: const Icon(Icons.qr_code_2, size: 44, color: AppColors.slate500));
}

class ContactRow extends StatelessWidget {
  const ContactRow({super.key, required this.name, required this.detail});
  final String name;
  final String detail;
  @override
  Widget build(BuildContext context) => InkWell(onTap: () => dialNumber(context, detail.contains('987') ? '+15559876543' : '+15551234567'), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)), const SizedBox(height: 4), Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.slate500))])), const CircleAvatar(backgroundColor: Color(0xFFEAFBF4), child: Icon(Icons.phone, color: AppColors.success, size: 18))])));
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.left, required this.right});
  final String left;
  final String right;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(left, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900))), Text(right, style: const TextStyle(fontSize: 12, color: AppColors.slate500))]);
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.icon, required this.label, required this.value, this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap ?? () => showAppMessage(context, '$label settings opened.'), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [TintIcon(icon: icon, color: AppColors.slate600), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900))), if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 12, color: AppColors.slate500)), const SizedBox(width: 6), const Icon(Icons.chevron_right, color: AppColors.slate500)])));
}

class IconListRow extends StatelessWidget {
  const IconListRow({super.key, required this.icon, required this.color, required this.title, this.subtitle});
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(16), child: Row(children: [TintIcon(icon: icon, color: color), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.slate900)), if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.slate500))]]))]));
}

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.label, required this.hint, this.controller});
  final String label;
  final String hint;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionLabel(label), const SizedBox(height: 8), TextField(controller: controller, keyboardType: label == 'Date of Birth' ? TextInputType.datetime : TextInputType.text, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary))))]);
}

class AppSelect extends StatefulWidget {
  const AppSelect({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  late String value = widget.value;

  List<String> get options => switch (widget.label) {
    'Relation' => ['Spouse', 'Parent', 'Child', 'Sibling', 'Other'],
    'Blood Group' => ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    'Gender' => ['Female', 'Male', 'Non-binary', 'Prefer not to say'],
    _ => ['Select...'],
  };

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionLabel(widget.label), const SizedBox(height: 8), DropdownButtonFormField<String>(value: value == 'Select...' ? null : value, isExpanded: true, hint: const Text('Select...'), items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(), onChanged: (next) => setState(() => value = next ?? widget.value), decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary))))]);
}

IconData _eventIcon(String type) {
  switch (type) {
    case 'consultation':
      return Icons.medical_services_outlined;
    case 'report':
      return Icons.description_outlined;
    case 'prescription':
      return Icons.medication_outlined;
    case 'vaccination':
      return Icons.shield_outlined;
    default:
      return Icons.monitor_heart_outlined;
  }
}

Color _eventColor(String type) {
  switch (type) {
    case 'consultation':
      return AppColors.primary;
    case 'report':
      return AppColors.info;
    case 'prescription':
      return AppColors.purple;
    case 'vaccination':
      return AppColors.success;
    default:
      return AppColors.warning;
  }
}

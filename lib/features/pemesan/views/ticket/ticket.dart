import 'package:flutter/material.dart';
import '../../../../shared/widgets/searchbar.dart';
import '../../../../shared/widgets/ticket_card.dart';
import '../../../../core/constants/app_theme.dart';
import 'ticket_details.dart';

class TicketView extends StatefulWidget {
  const TicketView({super.key});

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  int _selectedTab = 0; // 0 for Ticket (Active), 1 for Riwayat (History)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: CustomSearchBar(
                hintText: 'Cari tiket kamu',
                showFilter: false,
              ),
            ),

            // 2. Custom Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabItem(0, 'Ticket'),
                  _buildTabItem(1, 'Riwayat'),
                ],
              ),
            ),
            const Divider(color: AppColors.neutral300, height: 1),
            const SizedBox(height: 24),

            // 3. Ticket List
            Expanded(
              child: _selectedTab == 0
                  ? _buildActiveTickets()
                  : _buildHistoryTickets(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              label,
              style: isSelected
                  ? AppTextStyles.semiBold(16, AppColors.sky500)
                  : AppTextStyles.medium(16, AppColors.neutral500),
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.sky500 : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTickets() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        TicketCard(
          title: 'IPB Innovation Expo',
          organizerName: 'IPB University',
          date: 'Sen, 1 Agustus',
          time: '08.00 - 13.00',
          location: 'IPB University',
          imageUrl: 'https://picsum.photos/id/10/200/200',
          isHistory: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'AniKanjo Matsuri 12',
          organizerName: 'Kanjo Project',
          date: 'Sab, 13 Januari',
          time: '10.00 - 21.00',
          location: 'Grand Ballroom Sudirman',
          imageUrl: 'https://picsum.photos/id/11/200/200',
          isHistory: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'Bogor Coffee Festival',
          organizerName: 'Asosiasi Barista Bogor',
          date: 'Sab, 22 Agustus',
          time: '10.00 - 22.00',
          location: 'Botani Square',
          imageUrl: 'https://picsum.photos/id/12/200/200',
          isHistory: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'Final HOK Region Bogor',
          organizerName: 'Indonesia E-Sports Association',
          date: 'Sen, 1 Agustus',
          time: '08.00 - 13.00',
          location: 'Bogor',
          imageUrl: 'https://picsum.photos/id/13/200/200',
          isHistory: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHistoryTickets() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        TicketCard(
          title: 'Badminton ICL League',
          organizerName: 'PBSI Bogor',
          date: 'Sab, 8 Agustus',
          time: '08.00 - 17.00',
          location: 'GOR Pajajaran',
          imageUrl: 'https://picsum.photos/id/20/200/200',
          isHistory: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'Final DBL Surabaya',
          organizerName: 'DBL Indonesia',
          date: 'Sab, 25 Juli',
          time: '19.00 - 22.00',
          location: 'DBL Arena Surabaya',
          imageUrl: 'https://picsum.photos/id/21/200/200',
          isHistory: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'Gamelan Orchestration',
          organizerName: 'Kemenparekraf',
          date: 'Sel, 1 Desember',
          time: '19.30 - 21.30',
          location: 'Taman Ismail Marzuki',
          imageUrl: 'https://picsum.photos/id/22/200/200',
          isHistory: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TicketCard(
          title: 'Dev Fest 2026',
          organizerName: 'Google Developers',
          date: 'Sab, 20 Agustus',
          time: '10.00 - 15.00',
          location: 'BRIN, M.H. Thamrin',
          imageUrl: 'https://picsum.photos/id/23/200/200',
          isHistory: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TicketDetailsView(),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

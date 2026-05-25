import 'package:flutter/material.dart';
import '../../../../shared/widgets/searchbar.dart';
import '../../../../shared/widgets/ticket_card.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../blocs/ticket_bloc.dart';
import '../../models/ticket_model.dart';
import 'ticket_details.dart';

class TicketView extends StatefulWidget {
  const TicketView({super.key});

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  late final TicketBloc _ticketBloc;
  late final TextEditingController _searchController;
  int _selectedTab = 0; // 0 for Ticket (Active), 1 for Riwayat (History)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ticketBloc = TicketBloc();
    _ticketBloc.fetchMyTickets();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ticketBloc.dispose();
    super.dispose();
  }

  List<TicketModel> _filterTickets(List<TicketModel> tickets) {
    if (_searchQuery.isEmpty) return tickets;
    return tickets
        .where((t) => t.eventName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _ticketBloc.fetchMyTickets(),
          color: AppColors.sky500,
          child: Column(
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: CustomSearchBar(
                  controller: _searchController,
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
                child: ListenableBuilder(
                  listenable: _ticketBloc,
                  builder: (context, _) {
                    if (_ticketBloc.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.sky500,
                        ),
                      );
                    }

                    if (_ticketBloc.status == TicketStatus.error) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 64,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _ticketBloc.errorMessage ??
                                      'Gagal memuat tiket.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regular(
                                    14,
                                    AppColors.neutral500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _ticketBloc.fetchMyTickets(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.sky500,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final active = _filterTickets(_ticketBloc.activeTickets);
                    final history = _filterTickets(_ticketBloc.historyTickets);

                    final currentTickets = _selectedTab == 0 ? active : history;

                    if (currentTickets.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            'Tidak ada tiket ditemukan.',
                            style: AppTextStyles.regular(
                              14,
                              AppColors.neutral500,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: currentTickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final ticket = currentTickets[index];
                        return TicketCard(
                          title: ticket.eventName,
                          organizerName: ticket.organizerName,
                          date: ticket.dateStart ?? 'Tanggal TBA',
                          time: '',
                          location: ticket.venueName,
                          imageUrl:
                              AppConstants.resolveImageUrl(ticket.banner1x1),
                          isHistory: _selectedTab == 1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailsView(
                                  paymentId: ticket.paymentId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/destination.dart';
import '../models/route.dart' as booking;
import '../utils/format.dart';
import '../utils/theme.dart';
import 'common_widgets.dart';

/// The reusable route, travel dates, passenger selector, and search action.
class SearchCard extends StatefulWidget {
  final ValueChanged<SearchQuery> onSearch;
  final ValueChanged<String>? onTypeChanged;
  final bool compact;
  final SearchQuery? initialQuery;

  const SearchCard({
    super.key,
    required this.onSearch,
    this.onTypeChanged,
    this.compact = true,
    this.initialQuery,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late String _type;
  late DateTime _departure;
  late DateTime _return;
  late int _passengers;

  @override
  void initState() {
    super.initState();
    final query = widget.initialQuery;
    _fromController =
        TextEditingController(text: query?.from ?? 'Manila (MNL)');
    _toController = TextEditingController(text: query?.to ?? 'Cebu (CEB)');
    _type = query?.type ?? 'Flights';
    _departure = query?.date ?? DateTime(2025, 10, 15);
    _return = query?.returnDate ?? DateTime(2025, 10, 17);
    _passengers = query?.passengers ?? 1;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isReturn}) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate =
        isReturn && _departure.isAfter(today) ? _departure : today;
    final current = isReturn ? _return : _departure;
    final initialDate = current.isBefore(firstDate) ? firstDate : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isReturn) {
        _return = picked;
      } else {
        _departure = picked;
        if (_return.isBefore(picked)) _return = picked;
      }
    });
  }

  void _submit() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter both your origin and destination.')),
      );
      return;
    }
    if (from.toLowerCase() == to.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Your destination must differ from your origin.')),
      );
      return;
    }
    widget.onSearch(
      SearchQuery(
        type: _type,
        from: from,
        to: to,
        date: _departure,
        returnDate: _return,
        passengers: _passengers,
      ),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                  Text(
                    DateFormat(
                            widget.compact ? 'EEE, MMM d' : 'EEE, MMM d, yyyy')
                        .format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
        prefixIcon: Icon(
          label == 'From' ? Icons.flight_takeoff : Icons.flight_land,
          color: AppColors.primary,
          size: 19,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5EBF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _compactDateRange() {
    return InkWell(
      onTap: () => _pickDate(isReturn: false),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${DateFormat('EEE, MMM d').format(_departure)} – '
                '${DateFormat('EEE, MMM d').format(_return)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.edit_calendar_outlined,
                size: 17, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _routeFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              _locationField('From', _fromController),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  tooltip: 'Swap locations',
                  onPressed: _swapLocations,
                  icon: const Icon(Icons.swap_vert),
                  color: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              _locationField('To', _toController),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _locationField('From', _fromController)),
            IconButton(
              tooltip: 'Swap locations',
              onPressed: _swapLocations,
              icon: const Icon(Icons.swap_horiz),
              color: AppColors.primary,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(child: _locationField('To', _toController)),
          ],
        );
      },
    );
  }

  void _swapLocations() {
    final from = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = from;
  }

  @override
  Widget build(BuildContext context) {
    final dateFields = widget.compact
        ? _compactDateRange()
        : Column(
            children: [
              _dateField('Departure Date', _departure,
                  () => _pickDate(isReturn: false)),
              const SizedBox(height: 10),
              _dateField(
                  'Return Date', _return, () => _pickDate(isReturn: true)),
            ],
          );

    return Card(
      elevation: 5,
      shadowColor: AppColors.dark.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(widget.compact ? 15 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentToggle(
              options: const ['Flights', 'Sea Boats'],
              selected: _type,
              onChanged: (value) {
                setState(() => _type = value);
                widget.onTypeChanged?.call(value);
              },
            ),
            const SizedBox(height: 14),
            _routeFields(),
            const SizedBox(height: 11),
            dateFields,
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int>(
                      value: _passengers,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        for (var count = 1; count <= 6; count++)
                          DropdownMenuItem(
                            value: count,
                            child: Text(
                              '$count Passenger${count == 1 ? '' : 's'}, Economy',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _passengers = value ?? 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.search),
                label: Text(
                    _type == 'Flights' ? 'Search Flights' : 'Search Sea Boats'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Destination photo card with a local gradient fallback if the network fails.
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback? onTap;
  final double width;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.width = 182,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PhotoFallback(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const _PhotoFallback(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(destination.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB323), size: 15),
                        Text(destination.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(destination.province,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 10)),
                    Text(
                      destination.famousFor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 9),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('From ${peso(destination.price)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(destination.travelType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One mock popular route row, reusable on Search and other discovery views.
class RouteTile extends StatelessWidget {
  final booking.Route route;
  final VoidCallback? onTap;

  const RouteTile({super.key, required this.route, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFlight = route.type == 'Flights';
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF1FF),
          child: Icon(isFlight ? Icons.flight : Icons.directions_boat,
              color: AppColors.primary),
        ),
        title: Text('${route.from} → ${route.to}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle:
            Text('${isFlight ? '' : 'Sea Trip • '}From ${peso(route.price)}'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}

/// Colored status label for confirmed, upcoming, and past bookings.
class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Confirmed' => AppColors.success,
      'Upcoming' => AppColors.primary,
      _ => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Flight or boat booking summary with a responsive text column.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isFlight = booking.type == 'Flights';
    final imageUrl = isFlight
        ? 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=300'
        : 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 70,
                  height: 78,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PhotoFallback(
                        icon: isFlight ? Icons.flight : Icons.directions_boat),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const _PhotoFallback(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(label: booking.label),
                    const SizedBox(height: 5),
                    Text('${booking.from} → ${booking.to}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                        '${DateFormat('MMM d, yyyy').format(booking.date)} • ${booking.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.muted)),
                    Text('${booking.carrier} • ${booking.code}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.muted)),
                    if (booking.totalPrice > 0)
                      Text(
                        '${peso(booking.totalPrice)} • ${booking.paymentMethod}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.primary),
                      ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete booking',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 38,
                    height: 38,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                    size: 21,
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile detail row used in the personal-information section.
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: onTap,
    );
  }
}

/// Five-tab navigation bar shared by every top-level screen.
class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.search_outlined, Icons.search, 'Search'),
    (Icons.confirmation_num_outlined, Icons.confirmation_num, 'Bookings'),
    (Icons.notifications_none, Icons.notifications, 'Notifications'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x100D2B66), blurRadius: 12, offset: Offset(0, -3))
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedIndex == i
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          selectedIndex == i ? _items[i].$2 : _items[i].$1,
                          color: selectedIndex == i
                              ? Colors.white
                              : AppColors.muted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selectedIndex == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selectedIndex == i
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  final IconData icon;

  const _PhotoFallback({this.icon = Icons.landscape_outlined});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDEBFA),
      alignment: Alignment.center,
      child: Icon(icon, size: 28, color: AppColors.primary),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/penginapan.dart';
import '../widgets/app_image.dart';
import '../services/pemesanan_service.dart';
import '../routes.dart';

const Color airgngPink = AppColors.primary;
const Color ink = AppColors.text;

class BookingPage extends StatefulWidget {
  final Penginapan penginapan;
  const BookingPage({super.key, required this.penginapan});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int step = 0;
  int guests = 1;
  DateTime checkIn = DateTime(2026, 12, 4);
  DateTime checkOut = DateTime(2026, 12, 6);
  String paymentMethod = 'Kartu kredit atau debit';
  String paymentTiming = 'Sekarang';

  int get nights => checkOut.difference(checkIn).inDays;
  int get total => nights * widget.penginapan.hargaPerMalam;

  String money(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString()},00';
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> editDates() async {
    final pickedIn = await showDatePicker(
      context: context,
      initialDate: checkIn,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Pilih tanggal check-in',
    );
    if (pickedIn == null || !mounted) return;

    final pickedOut = await showDatePicker(
      context: context,
      initialDate: checkOut.isAfter(pickedIn)
          ? checkOut
          : pickedIn.add(const Duration(days: 1)),
      firstDate: pickedIn.add(const Duration(days: 1)),
      lastDate: DateTime(2031, 12, 31),
      helpText: 'Pilih tanggal check-out',
    );
    if (pickedOut == null || !mounted) return;

    setState(() {
      checkIn = pickedIn;
      checkOut = pickedOut;
    });
  }

  void editGuests() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        int draftGuests = guests;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Jumlah tamu'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tamu dewasa'),
                Row(
                  children: [
                    IconButton(
                      onPressed: draftGuests > 1
                          ? () => setDialogState(() => draftGuests--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$draftGuests'),
                    IconButton(
                      onPressed: draftGuests < 10
                          ? () => setDialogState(() => draftGuests++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() => guests = draftGuests);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showPriceDetails() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Perincian harga',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 18),
            PriceRow(
              label: '$nights malam × ${money(1751374)}',
              value: money(total),
            ),
            const PriceRow(label: 'Biaya layanan', value: 'Termasuk'),
            const Divider(height: 24),
            PriceRow(label: 'Total IDR', value: money(total), bold: true),
          ],
        ),
      ),
    );
  }

  void showPolicy() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 8, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan pembatalan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Pembatalan gratis sebelum 29 November 2026. '
              'Bila membatalkan sebelum batas tersebut, pengembalian dana '
              'penuh berlaku dalam simulasi ini. Setelah batas waktu, '
              'biaya pembatalan dapat berlaku sesuai ketentuan akomodasi.',
            ),
          ],
        ),
      ),
    );
  }

  void goTo(int value) => setState(() => step = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _TopBar(
                  title: step == 0
                      ? 'Pemesanan kamar'
                      : step == 1
                      ? 'Tambahkan metode pembayaran'
                      : step == 2
                      ? 'Konfirmasikan dan bayar'
                      : 'Pemesanan dikonfirmasi',
                  onBack: step == 3
                      ? null
                      : () =>
                            step == 0 ? Navigator.pop(context) : goTo(step - 1),
                  onClose: () {
                    if (step == 3) {
                      _selesai();
                    } else if (step == 0) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else {
                      goTo(step - 1);
                    }
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                    children: [
                      _Progress(step: step),
                      const SizedBox(height: 8),
                      if (step == 0) _reviewScreen(),
                      if (step == 1) _paymentScreen(),
                      if (step == 2) _confirmationScreen(),
                      if (step == 3) _successScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ScreenTitle('Tinjau dan lanjutkan'),
        const SizedBox(height: 8),
        _Panel(
          children: [
            _PropertyCard(penginapan: widget.penginapan),
            _sectionRow(
              'Tanggal',
              '${formatDate(checkIn)} – ${formatDate(checkOut)}',
              onEdit: editDates,
              extra: '♥ Jarang tersedia',
            ),
            _sectionRow('Tamu', '$guests dewasa', onEdit: editGuests),
            _sectionRow(
              'Harga total',
              '${money(total)} IDR',
              actionLabel: 'Detail',
              onEdit: showPriceDetails,
            ),
            _sectionRow(
              'Pembatalan gratis',
              'Bila membatalkan sebelum 29 November, Anda akan mendapatkan pengembalian uang penuh.',
              actionLabel: 'Kebijakan lengkap',
              onEdit: showPolicy,
              multiline: true,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Pilih tanggal pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _Panel(
          children: [
            _RadioRow(
              title: 'Bayar ${money(total)} sekarang',
              subtitle: 'Bayar seluruh jumlah hari ini',
              selected: paymentTiming == 'Sekarang',
              onTap: () => setState(() => paymentTiming = 'Sekarang'),
            ),
            _RadioRow(
              title: 'Bayar Rp 0 sekarang',
              subtitle:
                  'Biaya sebesar ${money(total)} dikenakan pada 21 Nov 2026',
              selected: paymentTiming == 'Nanti',
              onTap: () => setState(() => paymentTiming = 'Nanti'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PrimaryButton(label: 'Selanjutnya', onPressed: () => goTo(1)),
      ],
    );
  }

  Widget _sectionRow(
    String title,
    String subtitle, {
    VoidCallback? onEdit,
    String actionLabel = 'Ubah',
    String? extra,
    bool multiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF444444),
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    extra,
                    style: const TextStyle(
                      color: airgngPink,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (multiline && onEdit != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onEdit,
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!multiline && onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: ink,
                backgroundColor: const Color(0xFFF5F5F5),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _paymentScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ScreenTitle('Tambahkan metode pembayaran'),
        const SizedBox(height: 4),
        const Text(
          'Pilih metode pembayaran yang ingin digunakan untuk pemesanan ini.',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 18),
        _Panel(
          children: [
            _RadioRow(
              icon: Icons.credit_card,
              title: 'Kartu kredit atau debit',
              subtitle: 'VISA  ••',
              selected: paymentMethod == 'Kartu kredit atau debit',
              onTap: () =>
                  setState(() => paymentMethod = 'Kartu kredit atau debit'),
            ),
            _RadioRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'GoPay',
              subtitle: 'Pembayaran digital',
              selected: paymentMethod == 'GoPay',
              onTap: () => setState(() => paymentMethod = 'GoPay'),
            ),
          ],
        ),
        if (paymentMethod == 'Kartu kredit atau debit') ...[
          const SizedBox(height: 16),
          const Text(
            'Contoh prototype: jangan masukkan data kartu asli.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const _DemoField(label: 'Nomor kartu', hint: '1234 5678 9012 3456'),
          Row(
            children: const [
              Expanded(
                child: _DemoField(label: 'Valid hingga', hint: 'MM/YY'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DemoField(label: 'CVV', hint: '123'),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 14),
          const _Notice(
            text:
                'GoPay dipilih. Pada aplikasi nyata, pengguna akan '
                'diarahkan ke proses otorisasi pembayaran GoPay.',
          ),
        ],
        const SizedBox(height: 12),
        const _Notice(
          text:
              '🔒 Informasi pembayaran ini hanya simulasi. Tidak ada '
              'transaksi yang dilakukan.',
        ),
        const SizedBox(height: 12),
        _PrimaryButton(label: 'Selanjutnya', onPressed: () => goTo(2)),
        TextButton(
          onPressed: () => goTo(0),
          child: const Text(
            '← Kembali ke tinjauan',
            style: TextStyle(color: ink),
          ),
        ),
      ],
    );
  }

  Widget _confirmationScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ScreenTitle('Konfirmasikan dan bayar'),
        const SizedBox(height: 8),
        _Panel(
          children: [
            _PropertyCard(penginapan: widget.penginapan),
            _sectionRow(
              'Tanggal',
              '${formatDate(checkIn)} – ${formatDate(checkOut)}',
              onEdit: editDates,
            ),
            _sectionRow(
              '$guests dewasa',
              'Maksimum 10 tamu bisa menginap di sini.',
              onEdit: editGuests,
            ),
            _sectionRow(
              'Harga total',
              '${money(total)} IDR',
              actionLabel: 'Detail',
              onEdit: showPriceDetails,
            ),
            _sectionRow(
              'Pembatalan gratis',
              'Bila membatalkan sebelum 29 November, Anda akan mendapatkan pengembalian uang penuh.',
              actionLabel: 'Kebijakan lengkap',
              onEdit: showPolicy,
              multiline: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          title: 'Kapan Anda akan membayar',
          subtitle: paymentTiming == 'Sekarang'
              ? '${money(total)} sekarang'
              : 'Rp 0 sekarang · ditagih 21 Nov 2026',
          onTap: () => goTo(0),
        ),
        _SummaryTile(
          title: 'Metode pembayaran',
          subtitle: paymentMethod,
          onTap: () => goTo(1),
        ),
        const SizedBox(height: 14),
        const Text(
          'Perincian harga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        PriceRow(
          label: '$nights malam × ${money(1751374)}',
          value: money(total),
        ),
        const Divider(height: 24),
        PriceRow(label: 'Total IDR', value: money(total), bold: true),
        TextButton(
          onPressed: showPriceDetails,
          child: const Text(
            'Perincian harga',
            style: TextStyle(color: ink, decoration: TextDecoration.underline),
          ),
        ),
        _PrimaryButton(
          label: _menyimpan ? 'Memproses...' : 'Konfirmasikan dan bayar',
          onPressed: () {
            if (!_menyimpan) _konfirmasi();
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Dengan menekan tombol, Anda menyetujui ketentuan pemesanan. '
          'Ini hanya simulasi untuk tugas UTS.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Color(0xFF555555)),
        ),
      ],
    );
  }

  Widget _successScreen() {
    return Column(
      children: [
        const SizedBox(height: 28),
        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F6EC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF267B45),
            size: 46,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pemesanan berhasil!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Terima kasih! Simulasi pemesanan kamar Airgng kamu telah selesai.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF666666)),
        ),
        const SizedBox(height: 22),
        _Panel(
          children: [
            _PropertyCard(penginapan: widget.penginapan),
            _sectionRow('Kode pemesanan', '-'),
            _sectionRow(
              'Tanggal menginap',
              '${formatDate(checkIn)} – ${formatDate(checkOut)}',
            ),
            _sectionRow('Jumlah tamu', '$guests dewasa'),
            _sectionRow('Metode pembayaran', paymentMethod),
            _sectionRow('Total simulasi', money(total)),
          ],
        ),
        const SizedBox(height: 14),
        const _Notice(
          text:
              'Prototype selesai. Tidak ada kamar yang benar-benar '
              'dipesan atau pembayaran yang diproses.',
        ),
        const SizedBox(height: 12),
        _PrimaryButton(label: 'Selesai', onPressed: _selesai),
      ],
    );
  }

  void _selesai() {
    // Bangun ulang halaman utama sehingga tab Jelajahi yang aktif
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (route) => false,
    );
  }

  bool _menyimpan = false;
  String? kodePemesanan;

  String _tgl(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _konfirmasi() async {
    setState(() => _menyimpan = true);
    try {
      final hasil = await PemesananService().buat(
        penginapanId: widget.penginapan.id,
        tanggalMasuk: _tgl(checkIn),
        tanggalKeluar: _tgl(checkOut),
        jumlahTamu: guests,
        metodePembayaran: paymentMethod,
        waktuPembayaran: paymentTiming == 'Sekarang' ? 'sekarang' : 'nanti',
      );
      if (!mounted) return;
      setState(() {
        kodePemesanan = hasil.kode;
        step = 3; // layar sukses
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onBack,
            icon: Icon(
              onBack == null ? Icons.arrow_back : Icons.arrow_back,
              size: 22,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 22),
          ),
        ),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  final int step;
  const _Progress({required this.step});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      3,
      (i) => Expanded(
        child: Container(
          height: 3,
          margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
          decoration: BoxDecoration(
            color: step < 3 && i <= step ? airgngPink : const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),
  );
}

class _ScreenTitle extends StatelessWidget {
  final String text;
  const _ScreenTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 22,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Panel extends StatelessWidget {
  final List<Widget> children;
  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E5E5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _PropertyCard extends StatelessWidget {
  final Penginapan penginapan;
  const _PropertyCard({required this.penginapan});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: AppImage(penginapan.gambar, width: 78, height: 70),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                penginapan.judul,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '★ ${penginapan.rating.toString().replaceAll('.', ',')}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RadioRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 23, color: const Color(0xFF444444)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? ink : const Color(0xFFAAAAAA),
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ink,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: airgngPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    ),
  );
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F6F6),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
    ),
  );
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SummaryTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

class _DemoField extends StatelessWidget {
  final String label;
  final String hint;
  const _DemoField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
          ),
        ),
      ],
    ),
  );
}

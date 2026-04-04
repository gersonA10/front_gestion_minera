
import 'package:flutter/material.dart';

class PaymentInstallmentCard extends StatelessWidget {
  final int number;
  final String dueDate;
  final double amount;
  final double capital;
  final double interest;
  final String status;

  const PaymentInstallmentCard({
    super.key,
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.capital,
    required this.interest,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2530),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuota #$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence: $dueDate',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status == 'Pendiente'
                              ? const Color(0xFF2EA043)
                              : status == 'Futura'
                              ? Colors.grey
                              : const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: status == 'Pendiente'
                              ? const Color(0xFF2EA043)
                              : status == 'Futura'
                              ? Colors.grey
                              : const Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Capital: ',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                capital.toStringAsFixed(2),
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Interés: ',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                interest.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
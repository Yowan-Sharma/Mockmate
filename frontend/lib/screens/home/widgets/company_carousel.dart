import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/company.dart';
import 'company_card.dart';

class CompanyCarousel extends StatelessWidget {
  final List<Company> companies;

  const CompanyCarousel({
    super.key,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, // Fixed height to accommodate card content
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return CompanyCard(
            company: company,
            onTap: () {
              context.push('/setup', extra: {
                'company': company.name,
                'interviewType': 'technical',
                'interviewMode': 'company'
              });
            },
          );
        },
      ),
    );
  }
}

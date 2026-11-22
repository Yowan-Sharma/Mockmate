import 'package:flutter/material.dart';
import '../../../models/company.dart';
import '../../../models/sort_option.dart';
import '../../../services/api_service.dart';
import 'section_header.dart';
import 'company_carousel.dart';

class CompanySection extends StatefulWidget {
  const CompanySection({super.key});

  @override
  State<CompanySection> createState() => _CompanySectionState();
}

class _CompanySectionState extends State<CompanySection> {
  SortOption _currentSort = SortOption.relevance;
  List<Company> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final companies = await ApiService.getCompanies();
    if (mounted) {
      setState(() {
        _companies = companies;
        _isLoading = false;
        _sortCompanies(_currentSort);
      });
    }
  }

  void _sortCompanies(SortOption sortOption) {
    if (!mounted) return;
    setState(() {
      _currentSort = sortOption;
      switch (sortOption) {
        case SortOption.relevance:
          _companies.sort((a, b) => b.relevance.compareTo(a.relevance));
          break;
        case SortOption.ascending:
          _companies.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOption.descending:
          _companies.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Prepare by Company',
          subtitle: 'Get interview questions tailored to each company\'s style, role and expectations.',
          icon: Icons.business,
          iconColor: const Color(0xFFE11D48), // Rose color
          currentSort: _currentSort,
          onSortChanged: _sortCompanies,
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          CompanyCarousel(companies: _companies),
      ],
    );
  }
}

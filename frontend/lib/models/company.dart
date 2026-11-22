class Company {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final int relevance;

  const Company({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.relevance,
  });
}

final List<Company> mockCompanies = [
  const Company(
    id: 'google',
    name: 'Google',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
    description: 'Focuses on problem solving, system design and behavioral questions.',
    relevance: 5,
  ),
  const Company(
    id: 'microsoft',
    name: 'Microsoft',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
    description: 'Asks questions on technical depth, product thinking and leadership.',
    relevance: 4,
  ),
  const Company(
    id: 'amazon',
    name: 'Amazon',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg',
    description: 'Focuses on system design, coding and Leadership Principles.',
    relevance: 3,
  ),
  const Company(
    id: 'meta',
    name: 'Meta',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Meta_Platforms_Inc._logo.svg',
    description: 'Asks deep technical questions, system design and product sense.',
    relevance: 2,
  ),
  const Company(
    id: 'apple',
    name: 'Apple',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg',
    description: 'Focuses on technical problem solving, product mindset and behavioral questions.',
    relevance: 1,
  ),
];

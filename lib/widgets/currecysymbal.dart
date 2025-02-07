String getCurrencySymbol(String currency) {
  switch (currency) {
    case 'Euro':
      return '€';
    case 'USD':
      return '\$';
    case 'BTC':
      return '₿';
    case 'ETH':
      return 'Ξ';
    case 'Ğ': // Add custom icons or symbols as needed
      return 'Ğ';
    default:
      return ''; // Default to no symbol if currency is unrecognized
  }
}

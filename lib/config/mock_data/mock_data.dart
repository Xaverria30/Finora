class MockData {
  static final List<Map<String, dynamic>> mockCategories = [
    {
      'id': 'cat-1',
      'name': 'Makanan & Minuman',
      'icon': 'restaurant',
      'color': '#FF6B6B',
      'type': 'expense',
    },
    {
      'id': 'cat-2',
      'name': 'Transportasi',
      'icon': 'directions_car',
      'color': '#4ECDC4',
      'type': 'expense',
    },
    {
      'id': 'cat-3',
      'name': 'Hiburan',
      'icon': 'movie',
      'color': '#9775FA',
      'type': 'expense',
    },
    {
      'id': 'cat-4',
      'name': 'Kesehatan',
      'icon': 'local_hospital',
      'color': '#FF6B9D',
      'type': 'expense',
    },
    {
      'id': 'cat-5',
      'name': 'Gaji',
      'icon': 'monetization_on',
      'color': '#51CF66',
      'type': 'income',
    },
    {
      'id': 'cat-6',
      'name': 'Bonus',
      'icon': 'card_giftcard',
      'color': '#74B9FF',
      'type': 'income',
    },
  ];

  static final List<Map<String, dynamic>> mockTransactions = [
    {
      'id': 'tx-1',
      'categoryId': 'cat-1',
      'amount': 75000,
      'type': 'expense',
      'description': 'Makan siang di restoran',
    },
    {
      'id': 'tx-2',
      'categoryId': 'cat-2',
      'amount': 50000,
      'type': 'expense',
      'description': 'Bensin kendaraan',
    },
    {
      'id': 'tx-3',
      'categoryId': 'cat-5',
      'amount': 10000000,
      'type': 'income',
      'description': 'Gaji bulanan',
    },
    {
      'id': 'tx-4',
      'categoryId': 'cat-3',
      'amount': 100000,
      'type': 'expense',
      'description': 'Tiket bioskop',
    },
  ];

  static final List<Map<String, dynamic>> mockBudgets = [
    {
      'id': 'bgt-1',
      'categoryId': 'cat-1',
      'categoryName': 'Makanan & Minuman',
      'limitAmount': 500000,
      'spent': 250000,
    },
    {
      'id': 'bgt-2',
      'categoryId': 'cat-2',
      'categoryName': 'Transportasi',
      'limitAmount': 300000,
      'spent': 150000,
    },
  ];

  static final List<Map<String, dynamic>> mockSavingGoals = [
    {
      'id': 'goal-1',
      'name': 'Dana Darurat',
      'description': 'Tabungan untuk keadaan darurat',
      'targetAmount': 10000000,
      'currentAmount': 5000000,
    },
    {
      'id': 'goal-2',
      'name': 'Liburan ke Bali',
      'description': 'Tabungan untuk liburan',
      'targetAmount': 20000000,
      'currentAmount': 8000000,
    },
  ];
}

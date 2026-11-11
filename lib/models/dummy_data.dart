final List<Map<String, dynamic>> dummyPlayers = [
  {
    'name': 'Kai',
    'role': 'READY',
    'isReady': true,
    'image':
        'https://images.unsplash.com/photo-1644353224392-7e532d7b8f4b?w=100',
  },
  {
    'name': 'Mika',
    'role': 'READY',
    'isReady': true,
    'image':
        'https://images.unsplash.com/photo-1615511676788-240d40160fbc?w=100',
  },
  {
    'name': 'Ryo',
    'role': 'READY',
    'isReady': true,
    'image':
        'https://images.unsplash.com/photo-1580983696793-3500a8a0b7f4?w=100',
  },
  {
    'name': 'Jett',
    'role': 'Roam',
    'isReady': false,
    'image':
        'https://images.unsplash.com/photo-1580935727530-99e8732bc21e?w=100',
  },
];

final List<Map<String, dynamic>> dummyMessages = [
  {
    'id': 1,
    'author': 'Kai',
    'text': 'Everyone good for a ranked run tonight?',
    'time': '9:36 PM',
    'mine': false,
  },
  {
    'id': 2,
    'author': 'Mika',
    'text': 'Locked in. I\'ve got one warm-up left.',
    'time': '9:37 PM',
    'mine': false,
    'reaction': 'READY 3',
  },
  {
    'id': 3,
    'author': 'You',
    'text': 'Give me five. Loading up now.',
    'time': '9:38 PM',
    'mine': true,
  },
];

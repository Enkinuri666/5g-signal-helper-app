import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'prompt_seeds.dart';

abstract final class SeedData {
  static const _uuid = Uuid();

  static Future<void> insertDefaults(Database db) async {
    final batch = db.batch();
    for (final cat in _defaultCategories) {
      batch.insert('categories', {
        'id': _uuid.v4(),
        'name': cat['name'],
        'parent_id': '',
        'icon': cat['icon'] ?? '',
        'color': cat['color'] ?? '',
        'sort_order': cat['sort'] ?? 0,
      });
    }
    await batch.commit(noResult: true);

    await _insertSubcategories(db);
    await _insertPromptSeeds(db);
  }

  static Future<void> _insertPromptSeeds(Database db) async {
    final prompts = PromptSeeds.all;
    final batch = db.batch();
    for (final prompt in prompts) {
      batch.insert('prompts', prompt);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _insertSubcategories(Database db) async {
    final parents = await db.query('categories', where: "parent_id = ''");
    final parentMap = {for (final p in parents) p['name'] as String: p['id'] as String};

    final batch = db.batch();
    for (final entry in _subcategories.entries) {
      final parentId = parentMap[entry.key];
      if (parentId == null) continue;
      for (var i = 0; i < entry.value.length; i++) {
        batch.insert('categories', {
          'id': _uuid.v4(),
          'name': entry.value[i],
          'parent_id': parentId,
          'icon': '',
          'color': '',
          'sort_order': i,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  static const List<Map<String, dynamic>> _defaultCategories = [
    {'name': 'Artificial Intelligence', 'icon': 'smart_toy', 'color': '00E7FF', 'sort': 0},
    {'name': 'Programming', 'icon': 'code', 'color': '7A5CFF', 'sort': 1},
    {'name': 'Image Generation', 'icon': 'image', 'color': 'FF6B9D', 'sort': 2},
    {'name': 'Video Generation', 'icon': 'videocam', 'color': 'FFB347', 'sort': 3},
    {'name': 'Cybersecurity', 'icon': 'security', 'color': 'FF4466', 'sort': 4},
    {'name': 'Web Automation', 'icon': 'auto_fix_high', 'color': '00FF9D', 'sort': 5},
    {'name': 'Windows', 'icon': 'desktop_windows', 'color': '00A4EF', 'sort': 6},
    {'name': 'Linux', 'icon': 'terminal', 'color': 'FCC624', 'sort': 7},
    {'name': 'Networking', 'icon': 'lan', 'color': '4FC3F7', 'sort': 8},
    {'name': 'Self-Hosting', 'icon': 'dns', 'color': '81C784', 'sort': 9},
    {'name': 'Research & Knowledge', 'icon': 'school', 'color': 'CE93D8', 'sort': 10},
    {'name': 'Business', 'icon': 'business_center', 'color': 'FFD54F', 'sort': 11},
    {'name': 'Creative', 'icon': 'palette', 'color': 'F06292', 'sort': 12},
    {'name': 'Media Processing', 'icon': 'movie_edit', 'color': 'FF8A65', 'sort': 13},
    {'name': 'IPTV & Streaming', 'icon': 'live_tv', 'color': '4DD0E1', 'sort': 14},
    {'name': 'Finance & Analytics', 'icon': 'analytics', 'color': '66BB6A', 'sort': 15},
    {'name': 'Web Research', 'icon': 'travel_explore', 'color': '7986CB', 'sort': 16},
    {'name': 'Knowledge Management', 'icon': 'library_books', 'color': 'A1887F', 'sort': 17},
    {'name': 'Personal Archive', 'icon': 'inventory_2', 'color': '90A4AE', 'sort': 18},
    {'name': 'Reverse Engineering', 'icon': 'bug_report', 'color': 'EF5350', 'sort': 19},
  ];

  static const Map<String, List<String>> _subcategories = {
    'Artificial Intelligence': [
      'Prompt Engineering', 'Agent Design', 'Multi-Agent Systems', 'AI Workflows',
      'MCP Servers', 'RAG', 'Local LLMs', 'Fine-Tuning', 'AI Evaluation',
      'AI Benchmarks', 'AI Safety Research', 'Model Comparison',
      'Structured Outputs', 'Function Calling', 'ChatGPT', 'Claude',
      'Gemini', 'Grok', 'DeepSeek', 'Perplexity', 'Qwen', 'Llama',
    ],
    'Programming': [
      'Python', 'JavaScript', 'TypeScript', 'React', 'Next.js', 'Flutter',
      'HTML', 'CSS', 'SQL', 'APIs', 'GraphQL', 'WebSockets', 'Docker',
      'Git', 'Rust', 'Go', 'C#', 'Java', 'C++', 'PHP',
    ],
    'Image Generation': [
      'Photorealism', 'Cinematic', 'Portraits', 'Fashion', 'Architecture',
      'Product Photography', 'Fantasy', 'Sci-Fi', 'Anime', 'Comics',
      'Lighting', 'Camera Settings', 'Composition', 'Character Design',
      'Environment Design', 'Style References', 'Prompt Templates',
      'Negative Prompts', 'Prompt Optimization',
    ],
    'Video Generation': [
      'Cinematic Video', 'Commercials', 'Animation', 'Music Videos',
      'Short Films', 'Camera Motion', 'Storyboards', 'Character Consistency',
      'Video Editing', 'Prompt Templates',
    ],
    'Cybersecurity': [
      'Ethical Hacking', 'Penetration Testing', 'Red Team', 'Blue Team',
      'Purple Team', 'Web Security', 'Mobile Security', 'Wireless Security',
      'Network Security', 'Cloud Security', 'Secure Coding',
      'Digital Forensics', 'Malware Analysis', 'Reverse Engineering',
      'OSINT', 'Threat Intelligence', 'Incident Response', 'SIEM',
      'CTF', 'Vulnerability Research', 'Active Directory', 'Detection Engineering',
    ],
    'Web Automation': [
      'Playwright', 'Selenium', 'Puppeteer', 'Browser Automation',
      'Form Automation', 'API Automation', 'Data Pipelines', 'RPA',
      'Task Scheduling', 'Workflow Automation',
    ],
    'Windows': [
      'Windows 11', 'Performance Optimization', 'Registry', 'Group Policy',
      'PowerShell', 'WSL', 'Automation', 'Windows Internals', 'Drivers',
      'Diagnostics', 'Gaming Optimization', 'Windows Terminal',
      'Networking', 'Backup & Recovery',
    ],
    'Linux': [
      'Ubuntu', 'Debian', 'Arch', 'Fedora', 'Kali', 'Bash', 'Zsh',
      'Shell Scripting', 'Containers', 'Virtualization',
      'Services', 'System Administration',
    ],
    'Networking': [
      'TCP/IP', 'DNS', 'HTTP/HTTPS', 'HTTP/3', 'QUIC', 'VPN', 'VLAN',
      'WireGuard', 'Routing', 'Switching', 'Wi-Fi', 'IPv6',
      'Reverse Proxies', 'Load Balancing',
    ],
    'Self-Hosting': [
      'Docker', 'Kubernetes', 'Proxmox', 'Virtualization', 'NAS',
      'Home Lab', 'Reverse Proxy', 'Monitoring', 'Backups',
      'DNS', 'Containers',
    ],
    'Research & Knowledge': [
      'PDF Library', 'OCR', 'Academic Papers', 'White Papers',
      'Documentation', 'Personal Wiki', 'Knowledge Graph', 'Citations',
      'Semantic Search', 'Full-Text Search', 'Markdown Notes',
    ],
    'Business': [
      'Branding', 'Marketing', 'Sales', 'Finance', 'Legal',
      'Productivity', 'SOPs', 'Customer Support',
    ],
    'Creative': [
      'Logo Design', 'UI/UX', 'Graphic Design', 'Photography',
      'Audio', 'Music', 'Writing', 'Storytelling',
    ],
    'Media Processing': [
      'FFmpeg', 'HandBrake', 'Video Encoding', 'Audio Processing',
      'HDR', 'Dolby Vision', 'Subtitle Management', 'Batch Processing',
    ],
    'IPTV & Streaming': [
      'IPTV Players', 'M3U Playlist Management', 'Playlist Organization',
      'EPG Management', 'Channel Metadata', 'Logo Management',
      'Playlist Validation', 'Duplicate Detection', 'Playlist Merging',
      'VOD Metadata', 'Streaming Diagnostics', 'Buffer Analysis',
      'FFmpeg Workflows', 'Jellyfin', 'Plex', 'Kodi',
    ],
    'Finance & Analytics': [
      'Personal Finance', 'Investing Research', 'Sports Analytics',
      'Statistical Models', 'Probability', 'Risk Management',
      'Spreadsheet Models', 'Data Visualization',
    ],
    'Web Research': [
      'Web Scraping', 'HTML Parsing', 'CSS Selectors', 'XPath',
      'RSS', 'Sitemaps', 'Public Dataset Collection',
      'Metadata Extraction', 'API Research', 'Search Operators',
    ],
    'Knowledge Management': [
      'Templates', 'SOPs', 'Checklists', 'Decision Trees', 'Playbooks',
      'Workflows', 'Cheat Sheets', 'Snippets', 'Command References', 'Glossary',
    ],
    'Personal Archive': [
      'Notes', 'Journal', 'Experiments', 'Bookmarks', 'Saved Searches',
      'Attachments', 'Screenshots', 'Voice Notes', 'Projects', 'Ideas',
    ],
    'Reverse Engineering': [
      'Binary Analysis', 'Static Analysis', 'Dynamic Analysis',
      'Debugging', 'Decompilers', 'Assembly', 'x86/x64', 'ARM',
      'PE Format', 'ELF Format', 'Memory Analysis', 'Software Instrumentation',
    ],
  };
}

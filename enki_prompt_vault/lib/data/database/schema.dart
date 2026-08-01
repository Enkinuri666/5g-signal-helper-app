abstract final class DatabaseSchema {
  static const List<String> createStatements = [
    '''
    CREATE TABLE prompts (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT DEFAULT '',
      body TEXT NOT NULL,
      category TEXT DEFAULT 'General AI',
      subcategory TEXT DEFAULT '',
      tags TEXT DEFAULT '',
      ai_models TEXT DEFAULT '',
      difficulty TEXT DEFAULT 'Intermediate',
      variables TEXT DEFAULT '',
      expected_output TEXT DEFAULT '',
      example TEXT DEFAULT '',
      notes TEXT DEFAULT '',
      rating INTEGER DEFAULT 0,
      is_favorite INTEGER DEFAULT 0,
      is_pinned INTEGER DEFAULT 0,
      source TEXT DEFAULT '',
      personal_notes TEXT DEFAULT '',
      collection_id TEXT DEFAULT '',
      copy_count INTEGER DEFAULT 0,
      use_count INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      modified_at TEXT NOT NULL,
      last_used_at TEXT
    )
    ''',
    '''
    CREATE TABLE collections (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT DEFAULT '',
      icon TEXT DEFAULT 'folder',
      parent_id TEXT DEFAULT '',
      is_pinned INTEGER DEFAULT 0,
      sort_order INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      modified_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      parent_id TEXT DEFAULT '',
      icon TEXT DEFAULT '',
      color TEXT DEFAULT '',
      sort_order INTEGER DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE prompt_versions (
      id TEXT PRIMARY KEY,
      prompt_id TEXT NOT NULL,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      version_number INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE
    )
    ''',
    '''
    CREATE TABLE copy_history (
      id TEXT PRIMARY KEY,
      prompt_id TEXT NOT NULL,
      copied_at TEXT NOT NULL,
      FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE
    )
    ''',
    // FTS5 virtual table for fast full-text search
    '''
    CREATE VIRTUAL TABLE prompts_fts USING fts5(
      title,
      description,
      body,
      tags,
      notes,
      personal_notes,
      category,
      ai_models,
      content='prompts',
      content_rowid='rowid'
    )
    ''',
    // Indexes
    'CREATE INDEX idx_prompts_category ON prompts(category)',
    'CREATE INDEX idx_prompts_is_favorite ON prompts(is_favorite)',
    'CREATE INDEX idx_prompts_is_pinned ON prompts(is_pinned)',
    'CREATE INDEX idx_prompts_collection_id ON prompts(collection_id)',
    'CREATE INDEX idx_prompts_created_at ON prompts(created_at)',
    'CREATE INDEX idx_prompts_modified_at ON prompts(modified_at)',
    'CREATE INDEX idx_prompts_last_used_at ON prompts(last_used_at)',
    'CREATE INDEX idx_prompts_rating ON prompts(rating)',
    'CREATE INDEX idx_prompts_use_count ON prompts(use_count)',
    'CREATE INDEX idx_collections_parent_id ON collections(parent_id)',
    'CREATE INDEX idx_categories_parent_id ON categories(parent_id)',
    'CREATE INDEX idx_prompt_versions_prompt_id ON prompt_versions(prompt_id)',
    // Triggers to keep FTS in sync
    '''
    CREATE TRIGGER prompts_ai AFTER INSERT ON prompts BEGIN
      INSERT INTO prompts_fts(rowid, title, description, body, tags, notes, personal_notes, category, ai_models)
      VALUES (new.rowid, new.title, new.description, new.body, new.tags, new.notes, new.personal_notes, new.category, new.ai_models);
    END
    ''',
    '''
    CREATE TRIGGER prompts_ad AFTER DELETE ON prompts BEGIN
      INSERT INTO prompts_fts(prompts_fts, rowid, title, description, body, tags, notes, personal_notes, category, ai_models)
      VALUES ('delete', old.rowid, old.title, old.description, old.body, old.tags, old.notes, old.personal_notes, old.category, old.ai_models);
    END
    ''',
    '''
    CREATE TRIGGER prompts_au AFTER UPDATE ON prompts BEGIN
      INSERT INTO prompts_fts(prompts_fts, rowid, title, description, body, tags, notes, personal_notes, category, ai_models)
      VALUES ('delete', old.rowid, old.title, old.description, old.body, old.tags, old.notes, old.personal_notes, old.category, old.ai_models);
      INSERT INTO prompts_fts(rowid, title, description, body, tags, notes, personal_notes, category, ai_models)
      VALUES (new.rowid, new.title, new.description, new.body, new.tags, new.notes, new.personal_notes, new.category, new.ai_models);
    END
    ''',
  ];
}

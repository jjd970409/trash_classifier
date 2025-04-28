import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "trash_db.db");
    var theDb = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade); // 버전 3으로 업데이트
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE trash_items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL, category TEXT NOT NULL, description TEXT, category_image TEXT)'); // category_image 필드 추가
    await db.execute(
        'CREATE TABLE trash_details (id INTEGER PRIMARY KEY AUTOINCREMENT, trash_item_id INTEGER NOT NULL, step_order INTEGER NOT NULL, instruction TEXT NOT NULL, image_id INTEGER, FOREIGN KEY (trash_item_id) REFERENCES trash_items(id), FOREIGN KEY (image_id) REFERENCES trash_images(id))');
    await db.execute(
        'CREATE TABLE trash_images (id INTEGER PRIMARY KEY AUTOINCREMENT, file_path TEXT NOT NULL, alt_text TEXT)');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE trash_items ADD COLUMN category_image TEXT'); // category_image 필드 추가
    }
  }

  // 쓰레기 품목 추가 (category_image 포함)
  Future<int> insertTrashItem(Map<String, dynamic> trashItem) async {
    var dbClient = await db;
    return await dbClient!.insert('trash_items', trashItem);
  }

  // 상세 정보 단계 추가
  Future<int> insertTrashDetail(Map<String, dynamic> detail) async {
    var dbClient = await db;
    return await dbClient!.insert('trash_details', detail);
  }

  // 이미지 정보 추가
  Future<int> insertTrashImage(Map<String, dynamic> image) async {
    var dbClient = await db;
    return await dbClient!.insert('trash_images', image);
  }

  // 이름으로 쓰레기 품목 조회 (상세 정보 및 이미지 포함, category_image 포함)
  Future<List<Map<String, dynamic>>> getTrashItemByName(String name) async {
    var dbClient = await db;
    return await dbClient!.rawQuery('''
      SELECT
        ti.id AS item_id,
        ti.name,
        ti.category,
        ti.description,
        ti.category_image,
        td.id AS detail_id,
        td.step_order,
        td.instruction,
        img.id AS image_id,
        img.file_path,
        img.alt_text
      FROM trash_items ti
      LEFT JOIN trash_details td ON ti.id = td.trash_item_id
      LEFT JOIN trash_images img ON td.image_id = img.id
      WHERE ti.name LIKE ?
      ORDER BY td.step_order
    ''', ['%$name%']);
  }

  // ID로 쓰레기 품목 조회 (상세 정보 및 이미지 포함) - 상세 화면에서 사용
  Future<List<Map<String, dynamic>>> getTrashDetailsByItemId(int itemId) async {
    var dbClient = await db;
    return await dbClient!.rawQuery('''
      SELECT
        td.id AS detail_id,
        td.step_order,
        td.instruction,
        img.id AS image_id,
        img.file_path,
        img.alt_text
      FROM trash_details td
      LEFT JOIN trash_images img ON td.image_id = img.id
      WHERE td.trash_item_id = ?
      ORDER BY td.step_order
    ''', [itemId]);
  }

  // ... (필요한 CRUD 메소드)
}
import 'package:flutter/material.dart';
import 'trash_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchResult = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularSearches = ['페트병', '비닐 봉투', '음식물 쓰레기', '건전지', '형광등'];
  double _chipScale = 1.0; // 칩 스케일 애니메이션을 위한 변수
  List<String> _autocompleteResults = []; // 자동 완성 결과를 저장할 리스트
  bool _showAutocomplete = false; // 자동 완성 목록 표시 여부 상태

  void _searchTrash(String query) {
    setState(() {
      if (trashClassificationData.containsKey(query)) {
        _searchResult = query;
        _autocompleteResults.clear();
        _showAutocomplete = false; // 검색 완료 후 자동 완성 목록 숨김
      } else {
        _searchResult = query;
        _autocompleteResults.clear();
        _showAutocomplete = false; // 검색 완료 후 자동 완성 목록 숨김
      }
    });
  }

  void _animateChip(bool isPressed) {
    setState(() {
      _chipScale = isPressed ? 0.95 : 1.0; // 눌렀을 때 약간 작아지도록
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        _autocompleteResults = trashClassificationData.keys
            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
        _showAutocomplete = true; // 검색어 변경 시 자동 완성 목록 표시
      } else {
        _autocompleteResults.clear();
        _showAutocomplete = false; // 검색어 비어 있으면 목록 숨김
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쓰레기 분류 도우미'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector( // 배경 터치 감지를 위한 GestureDetector
            onTap: () {
              setState(() {
                _showAutocomplete = false; // 배경 터치 시 자동 완성 목록 숨김
              });
              FocusScope.of(context).unfocus(); // 키보드 닫기
            },
            behavior: HitTestBehavior.opaque, // GestureDetector가 전체 영역을 터치 대상으로 함
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '궁금한 쓰레기 이름을 검색해보세요.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: '예: 플라스틱 병, 폐건전지',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.green),
                        onPressed: () {
                          _searchTrash(_searchController.text);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    onChanged: _onSearchChanged, // 검색어 변경 시 호출
                    onSubmitted: (value) {
                      _searchTrash(value);
                      FocusScope.of(context).unfocus();
                    },
                    // onTapOutside 제거 (더 이상 배경 터치로 처리)
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '자주 찾는 쓰레기:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _popularSearches
                        .map((search) => GestureDetector(
                              onTap: () {
                                _searchController.text = search;
                                _searchTrash(search);
                                FocusScope.of(context).unfocus();
                              },
                              onTapDown: (details) => _animateChip(true), // 눌렀을 때
                              onTapUp: (details) => _animateChip(false),   // 눌렀다 뗐을 때
                              onTapCancel: () => _animateChip(false), // 탭이 취소되었을 때
                              child: AnimatedScale(
                                scale: _chipScale,
                                duration: const Duration(milliseconds: 100),
                                child: Chip(
                                  label: Text(search),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  if (_searchResult.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _searchResult,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.green[800],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trashClassificationData.containsKey(_searchResult)
                                ? trashClassificationData[_searchResult]!
                                : '해당하는 분리수거 정보를 찾을 수 없습니다.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_showAutocomplete && _autocompleteResults.isNotEmpty)
            Positioned(
              top: 115,
              left: 24,
              right: 24,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 170),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _autocompleteResults.length,
                    itemBuilder: (context, index) {
                      final result = _autocompleteResults[index];
                      return ListTile(
                        title: Text(result),
                        onTap: () {
                          _searchController.text = result;
                          _searchTrash(result);
                          setState(() {
                            _showAutocomplete = false; // 아이템 선택 후 목록 숨김
                          });
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPortfolioDetail extends StatefulWidget {
  final Map<String, dynamic> portfolioItem;
  final String user;

  SearchPortfolioDetail({required this.portfolioItem, required this.user});

  @override
  State<SearchPortfolioDetail> createState() => _SearchPortfolioDetailState();
}

class _SearchPortfolioDetailState extends State<SearchPortfolioDetail> {
  @override
  void initState() {
    super.initState();
    updatePortfolioCollection(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 300,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  // 이미지 클릭 시 추가 동작 수행
                },
                child: Image.network(
                  widget.portfolioItem['thumbnailUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('작성자 : ${widget.user}', style: TextStyle(fontSize: 18)),
                        Text('조회수 : ${widget.portfolioItem['cnt']}', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('카테고리 > ${widget.portfolioItem['category']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text(
                      widget.portfolioItem['title'] ?? '제목 없음',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      children: [
                        Text(
                          '${widget.portfolioItem['hashtags']?.join(', ') ?? '없음'}',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      height: 20,
                      color: Colors.grey,
                      thickness: 2,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "프로젝트 설명",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.portfolioItem['portfolioDescription'] ?? '설명 없음',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "참여 기간",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '참여기간 : ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['startDate'].toDate())}'
                          '~ ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['endDate'].toDate())}',
                    ),
                  ],
                ),
              )
            ]),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (widget.portfolioItem['subImageUrls'] != null && index < widget.portfolioItem['subImageUrls'].length) {
                  String imageUrl = widget.portfolioItem['subImageUrls'][index];
                  return GestureDetector(
                    onTap: () {
                      _showImageDialog(imageUrl);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              childCount: (widget.portfolioItem['subImageUrls'] ?? []).length,
            ),
          ),
        ],
      ),
    );
  }

  _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 500,
            width: 500,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("닫기"),
            )
          ],
        );
      },
    );
  }

  void updatePortfolioCollection(String user) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String documentId = user; // 'your_document_id'를 실제 문서 ID로 대체

    // 'portfolio' 서브컬렉션의 문서들을 가져옵니다.
    firestore.collection('expert').doc(documentId).collection('portfolio').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String title = doc['title'];

        if (title == widget.portfolioItem['title']) {
          if (doc.data().containsKey('cnt')) {
            int currentCount = doc['cnt'];
            int updatedCount = currentCount + 1;

            doc.reference.update({
              'cnt': updatedCount,
            });
          }
        }
      });
    });
  }


}

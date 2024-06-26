import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_news_app/controller/select_category_controller.dart';
import 'package:my_news_app/utilities/app_text.dart';
import '../controller/select_screen_controller.dart';
import '../model/article_model.dart';
import '../utilities/navigation_conts.dart';
import '../view_model/news_view_model.dart';
import 'news_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  NewsViewModel newsViewModel = NewsViewModel();

  SelectCategoryController categoryController = Get.put(SelectCategoryController());
  SelectScreenController screenController = Get.put(SelectScreenController());



  final format = DateFormat('MMMM dd, yyyy');
 
  List<String> categoriesList = [
    'General',
    'Entertainment',
    'Health',
    'Sports',
    'Business',
    'Technology'
  ];

  @override
  Widget build(BuildContext context) {
    double heightX = Get.height * 1;
    double widthX = Get.width * 1;
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: (){Get.back();},
            child: const Icon(Icons.arrow_back_ios_new)),
        backgroundColor: Colors.red,
        title: Text(
          'Categories',
          style: GoogleFonts.poppins(fontSize: 24,color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(()=> FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.red,
          shape: const StadiumBorder(),
          label: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(Navi.iconList.length, (int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                      onTap: () {
                        screenController.selectedIndex.value = Navi.checkList[index];
                        Get.to( Navi.screenList.elementAt(index));
                        if (kDebugMode) {
                          print(screenController.selectedIndex.value.toString());
                        }
                      },
                      child: screenController.selectedIndex.value ==  Navi.checkList[index]? Icon(Navi.iconListFilled.elementAt(index),
                          size: 35, color: Colors.white) :
                      Icon(Navi.iconList.elementAt(index),
                          size: 35, color: Colors.black45)),
                );
              }),
            ),
          ))
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: (){
                      categoryController.categoryName.value = categoriesList[index];
                    },
                    child: Obx(() => Container(
                      decoration: BoxDecoration(
                          color: categoryController.categoryName.value == categoriesList[index]? Colors.red : Colors.red.shade200,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(child: AppText(title: categoriesList[index].toString(),
                          textColor: Colors.white, fontSize: 13,
                        )),
                      ),
                    )),
                  ),
                );
              }),
            ),
            const SizedBox(height: 15,),
            Obx(() => Expanded(
              child: FutureBuilder(
                future: newsViewModel.fetchNewsCategoriesApi(categoryController.categoryName.value),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitFadingFour(
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  } else {
                    List<Article> articles = snapshot.data as List<Article>;
                    return ListView.builder(
                      itemCount: articles.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        Article article = articles[index];
                        DateTime dateTime = DateTime.parse(article.publishedAt.toString());
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: InkWell(
                            onTap:(){
                              String newsImage = article.urlToImage.toString();
                              String newsTitle = article.title.toString();
                              String newsDate = format.format(dateTime);
                              String newsAuthor = article.author.toString();
                              String newsDescription = article.description.toString();
                              String newsContent = article.content.toString();
                              String newsSource = article.source!.name.toString();
                              Get.to(()=> NewsDetailScreen(
                                  newsImage: newsImage,
                                  newsTitle: newsTitle,
                                  newsDate: newsDate,
                                  author: newsAuthor,
                                  description: newsDescription,
                                  content: newsContent,
                                  source: newsSource, newsUrl: article.url.toString(),
                              ));
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: article.urlToImage.toString(),
                                    fit: BoxFit.cover,
                                    height: heightX * 0.20,
                                    width: widthX * 0.3,
                                    placeholder: (context, url) =>
                                    const SpinKitDualRing(
                                      color: Colors.redAccent,
                                      size: 40,
                                    ),
                                    errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                      height: heightX * 0.20,
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        children: [
                                          AppText(title: article.title.toString(),
                                          textFontWeight: FontWeight.w700, fontSize: 15,
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppText(title: article.source!.name.toString(),
                                                textFontWeight: FontWeight.w500, textColor: Colors.blue,
                                                fontSize: 12,
                                              ),
                                              //=== date ===
                                              AppText(title: format.format(dateTime),
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}

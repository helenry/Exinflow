import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:exinflow/services/category.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/models/category.dart';
import 'dart:async'; 

// List
class Categories extends StatefulWidget {
  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  final user = FirebaseAuth.instance.currentUser;
  final CategoryService categoryService = CategoryService();
  final CategoryController categoryController = Get.find<CategoryController>();
  final SubtabController subtabController = Get.find<SubtabController>();
  late TabController categoriesTabController;
  late StreamSubscription<int> selectedTabSubscription;

  final List<Map> tabs = [
    {
      "tab": "Pengeluaran",
      "title": "Kategori Pengeluaran"
    },
    {
      "tab": "Pendapatan",
      "title": "Kategori Pendapatan"
    },
  ];

  @override
  void initState() {
    super.initState();
    Get.delete<TabController>();
    categoriesTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));

    selectedTabSubscription = subtabController.selectedTab.listen((index) {
      categoriesTabController.animateTo(index);
    });
  }

  @override
  void dispose() {
    subtabController.changeTab(0);
    selectedTabSubscription.cancel();
    Get.delete<TabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        id: '',
        title: "Kategori",
        menu: "Kategori",
        page: "All",
        type: '',
        from: '',
        subtype: 'category',
        subIndex: -1
      ),

      body: SingleChildScrollView(
        child: AllPadding(
          child: Column(
            children: [
              Subtab(tabs: tabs, controller: categoriesTabController),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        tabs[subtabController.selectedTab.value]['title'],
                        style: TextStyle(
                          fontSize: regular
                        ),
                      )
                    ],
                  ),
                );
              }),
              Obx(() {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Categories').where('User', isEqualTo: user?.uid ?? '').where('Type_Id', isEqualTo: subtabController.selectedTab.value).where('Is_Deleted', isEqualTo: false).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error");
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('');
                    }
                
                    categoryController.setLength(snapshot.data!.docs.length);
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var filteredDocs = snapshot.data!.docs.toList();
                        var doc = filteredDocs[index];
                
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          margin: EdgeInsets.only(bottom: index + 1 != snapshot.data!.docs.length ? 10 : 0),
                          decoration: BoxDecoration(
                            color: greyMinusFive,
                            borderRadius: borderRadius,
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
                                    return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
                                  }).toList();
                                  
                                  categoryController.setCategory(
                                    CategoryModel(
                                      id: doc.id,
                                      name: doc['Name'],
                                      typeId: doc['Type_Id'],
                                      subs: subs,
                                      icon: doc['Icon'],
                                      color: doc['Color'].toString(),
                                    )
                                  );
                                  context.push('/manage/categories/category/${doc.id}?action=view');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 45,
                                            height: 45,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: borderRadius,
                                              color: Color(int.parse('FF${doc['Color']}', radix: 16))
                                            ),
                                            child: Icon(
                                              icons[doc['Icon']],
                                              color: Colors.white,
                                              size: 30
                                            )
                                          ),
                                  
                                          Text(
                                            doc['Name'],
                                            style: TextStyle(
                                              fontSize: small,
                                              fontWeight: FontWeight.w500,
                                              color: greyMinusTwo
                                            )
                                          ),
                                        ],
                                      ),
                                      
                                      OutlinedButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: Icon(Icons.add),
                                                      title: Text('Tambah Subkategori'),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                  
                                                        List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
                                                          return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
                                                        }).toList();
                                                        
                                                        categoryController.setCategory(
                                                          CategoryModel(
                                                            id: doc.id,
                                                            name: doc['Name'],
                                                            typeId: doc['Type_Id'],
                                                            subs: subs,
                                                            icon: doc['Icon'],
                                                            color: doc['Color'].toString(),
                                                          )
                                                        );
                                  
                                                        context.push('/manage/categories/category/${doc.id}/subcategory');
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: Icon(Icons.edit),
                                                      title: Text('Ubah'),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                  
                                                        List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
                                                          return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
                                                        }).toList();
                                                        
                                                        categoryController.setCategory(
                                                          CategoryModel(
                                                            id: doc.id,
                                                            name: doc['Name'],
                                                            typeId: doc['Type_Id'],
                                                            subs: subs,
                                                            icon: doc['Icon'],
                                                            color: doc['Color'].toString(),
                                                          )
                                                        );
                                  
                                                        context.push('/manage/categories/category/${doc.id}?action=edit&from=dots');
                                                      },
                                                    ),
                                                    if(snapshot.data!.docs.length != 1)
                                                      ListTile(
                                                        leading: Icon(Icons.delete),
                                                        title: Text('Hapus'),
                                                        onTap: () async {
                                                          bool confirm = await showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  'Hapus',
                                                                  style: TextStyle(
                                                                    fontFamily: "Open Sans",
                                                                    fontWeight: FontWeight.w500,
                                                                    color: greyMinusTwo
                                                                  )
                                                                ),
                                                                content: Text(
                                                                  'Apakah Anda yakin ingin menghapus?',
                                                                  style: TextStyle(
                                                                    fontSize: tiny
                                                                  )
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: OutlinedButton(
                                                                          style: OutlinedButton.styleFrom(
                                                                            side: BorderSide(color: mainBlue),
                                                                            padding: EdgeInsets.symmetric(vertical: 10)
                                                                          ),
                                                                          child: Text(
                                                                            'Tidak',
                                                                            style: TextStyle(
                                                                              fontSize: tiny,
                                                                              fontWeight: FontWeight.w500
                                                                            )
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop(false);
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 10),
                                                                      Expanded(
                                                                        child: OutlinedButton(
                                                                          style: OutlinedButton.styleFrom(
                                                                            backgroundColor: mainBlue,
                                                                            side: BorderSide(color: mainBlue),
                                                                            padding: EdgeInsets.symmetric(vertical: 10)
                                                                          ),
                                                                          child: Text(
                                                                            'Ya',
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: tiny,
                                                                              fontWeight: FontWeight.w500
                                                                            ),
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop(true);
                                                                          },
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                                ],
                                                              );
                                                            }
                                                          );
                                  
                                                          if(confirm == true) {
                                                            Navigator.pop(context);
                                                          
                                                            Map<String, dynamic> result = await categoryService.deleteCategory(user?.uid ?? '', doc.id);
                                  
                                                            categoryController.setSubcategory(-1);
                                                            categoryController.setCategory(
                                                              CategoryModel(
                                                                id: '',
                                                                name: '',
                                                                typeId: -1,
                                                                subs: null,
                                                                icon: '',
                                                                color: '',
                                                              )
                                                            );
                                                          }
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: CircleBorder(),
                                          side: BorderSide(width: 1, color: greyMinusTwo),
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(40, 40),
                                        ),
                                        child: Icon(
                                          Icons.more_horiz_rounded,
                                          color: greyMinusTwo,
                                          size: 25
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                
                              if(doc['Subs'] != null)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: doc['Subs'].where((doc) => !doc['Is_Deleted']).length,
                                  itemBuilder: (context, subIndex) {
                                    var filteredDocs = doc['Subs'].where((sub) => !sub['Is_Deleted']).toList();
                                    var sub = filteredDocs[subIndex];
                
                                    return Container(
                                      padding: EdgeInsets.only(left: 30),
                                      margin: EdgeInsets.only(top: 7.5),
                                      decoration: BoxDecoration(
                                        color: greyMinusFive,
                                        borderRadius: borderRadius,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
                                            return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
                                          }).toList();
                
                                          categoryController.setSubcategory(subIndex);
                                          categoryController.setCategory(
                                            CategoryModel(
                                              id: doc.id,
                                              name: doc['Name'],
                                              typeId: doc['Type_Id'],
                                              subs: subs,
                                              icon: doc['Icon'],
                                              color: doc['Color'].toString(),
                                            )
                                          );
                                          context.push('/manage/categories/category/${doc.id}/subcategory/${subIndex}?action=view');
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  margin: EdgeInsets.only(right: 20),
                                                  decoration: BoxDecoration(
                                                    borderRadius: borderRadius,
                                                    color: Color(int.parse('FF${doc['Color']}', radix: 16))
                                                  ),
                                                  child: Icon(
                                                    icons[sub['Icon']],
                                                    color: Colors.white,
                                                    size: 25
                                                  )
                                                ),
                
                                                Text(
                                                  sub['Name'],
                                                  style: TextStyle(
                                                    fontSize: semiVerySmall,
                                                    fontWeight: FontWeight.w500,
                                                    color: greyMinusTwo
                                                  )
                                                ),
                                              ],
                                            ),
                
                                            OutlinedButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Container(
                                                      padding: EdgeInsets.all(16),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            leading: Icon(Icons.edit),
                                                            title: Text('Ubah'),
                                                            onTap: () {
                                                              Navigator.pop(context);
                
                                                              List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
                                                                return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
                                                              }).toList();
                                                              
                                                              categoryController.setSubcategory(subIndex);
                                                              categoryController.setCategory(
                                                                CategoryModel(
                                                                  id: doc.id,
                                                                  name: doc['Name'],
                                                                  typeId: doc['Type_Id'],
                                                                  subs: subs,
                                                                  icon: doc['Icon'],
                                                                  color: doc['Color'].toString(),
                                                                )
                                                              );
                
                                                              context.push('/manage/categories/category/${doc.id}/subcategory/$subIndex?action=edit&from=dots');
                                                            },
                                                          ),
                                                          ListTile(
                                                            leading: Icon(Icons.delete),
                                                            title: Text('Hapus'),
                                                            onTap: () async {
                                                              bool confirm = await showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                      'Hapus',
                                                                      style: TextStyle(
                                                                        fontFamily: "Open Sans",
                                                                        fontWeight: FontWeight.w500,
                                                                        color: greyMinusTwo
                                                                      )
                                                                    ),
                                                                    content: Text(
                                                                      'Apakah Anda yakin ingin menghapus?',
                                                                      style: TextStyle(
                                                                        fontSize: tiny
                                                                      )
                                                                    ),
                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child: OutlinedButton(
                                                                              style: OutlinedButton.styleFrom(
                                                                                side: BorderSide(color: mainBlue),
                                                                                padding: EdgeInsets.symmetric(vertical: 10)
                                                                              ),
                                                                              child: Text(
                                                                                'Tidak',
                                                                                style: TextStyle(
                                                                                  fontSize: tiny,
                                                                                  fontWeight: FontWeight.w500
                                                                                )
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop(false);
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 10),
                                                                          Expanded(
                                                                            child: OutlinedButton(
                                                                              style: OutlinedButton.styleFrom(
                                                                                backgroundColor: mainBlue,
                                                                                side: BorderSide(color: mainBlue),
                                                                                padding: EdgeInsets.symmetric(vertical: 10)
                                                                              ),
                                                                              child: Text(
                                                                                'Ya',
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: tiny,
                                                                                  fontWeight: FontWeight.w500
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop(true);
                                                                              },
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  );
                                                                }
                                                              );
                
                                                              if(confirm == true) {
                                                                Navigator.pop(context);
                                                              
                                                                Map<String, dynamic> result = await categoryService.deleteSubcategory(user?.uid ?? '', doc.id, subIndex);
                
                                                                categoryController.setSubcategory(-1);
                                                                categoryController.setCategory(
                                                                  CategoryModel(
                                                                    id: '',
                                                                    name: '',
                                                                    typeId: -1,
                                                                    subs: null,
                                                                    icon: '',
                                                                    color: '',
                                                                  )
                                                                );                
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                shape: CircleBorder(),
                                                side: BorderSide(width: 1, color: greyMinusTwo),
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(40, 40),
                                              ),
                                              child: Icon(
                                                Icons.more_horiz_rounded,
                                                color: greyMinusTwo,
                                                size: 25
                                              ),
                                            )
                                          ],
                                        )
                                      )
                                    );
                                  },
                                )
                            ],
                          )
                        );
                      },
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
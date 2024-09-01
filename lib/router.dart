import 'package:exinflow/widgets/bottom_bar.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exinflow/controllers/onboarding.dart';
import 'package:flutter/material.dart';

import 'package:exinflow/pages/starting_point/onboarding.dart';
import 'package:exinflow/pages/starting_point/sign_in_up.dart';
import 'package:exinflow/pages/menu/home.dart';
import 'package:exinflow/pages/menu/manage.dart';
import 'package:exinflow/pages/menu/speech_recognition.dart';
import 'package:exinflow/pages/menu/analytics.dart';
import 'package:exinflow/pages/menu/account.dart';

import 'package:exinflow/pages/feature/transactions.dart';
import 'package:exinflow/pages/feature/accounts.dart';
import 'package:exinflow/pages/feature/budgets.dart';
import 'package:exinflow/pages/feature/categories.dart';
import 'package:exinflow/pages/feature/credits.dart';
import 'package:exinflow/pages/feature/savings.dart';

import 'package:exinflow/pages/feature/detail/transaction.dart';
import 'package:exinflow/pages/feature/detail/account.dart';
import 'package:exinflow/pages/feature/detail/budget.dart';
import 'package:exinflow/pages/feature/detail/category.dart';
import 'package:exinflow/pages/feature/detail/credit.dart';
import 'package:exinflow/pages/feature/detail/saving.dart';


final OnboardingController onboardingController = Get.find();
final user = FirebaseAuth.instance.currentUser;

final GoRouter router = GoRouter(
  initialLocation: onboardingController.onboardingCompleted.value ? user == null ? '/signinup?type=1' : '/home' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => Onboarding()
    ),
    GoRoute(
      path: '/signinup',
      builder: (context, state) => SignInUp(
        type: int.parse(state.uri.queryParameters['type'].toString())
      )
    ),
    GoRoute(
      path: '/speechrecognition',
      builder: (context, state) => SpeechRecognition()
    ),
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomBar()
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Home()
        ),
        GoRoute(
          path: '/manage',
          builder: (context, state) => Manage(),
          routes: [
            // GoRoute(
            //   path: 'savings',
            //   builder: (context, state) => Savings(),
            //   routes: [
            //     GoRoute(
            //       path: 'saving',
            //       builder: (context, state) => SavingDetail(
            //         id: '',
            //         subIndex: -1,
            //         action: 'add',
            //         from: '',
            //         sub: 'saving',
            //       ),
            //     ),
            //     GoRoute(
            //       path: 'saving/:id',
            //       builder: (context, state) => SavingDetail(
            //         id: state.pathParameters['id']!,
            //         subIndex: -1,
            //         action: state.uri.queryParameters['action'].toString(),
            //         from: state.uri.queryParameters['from'].toString(),
            //         sub: 'saving',
            //       )
            //     ),
            //     GoRoute(
            //       path: 'saving/:id/record',
            //       builder: (context, state) => SavingDetail(
            //         id: '',
            //         subIndex: -1,
            //         action: 'add',
            //         from: '',
            //         sub: 'record',
            //       ),
            //     ),
            //     GoRoute(
            //       path: 'saving/:id/record/:subIndex',
            //       builder: (context, state) => SavingDetail(
            //         id: state.pathParameters['id']!,
            //         subIndex: -1,
            //         action: state.uri.queryParameters['action'].toString(),
            //         from: state.uri.queryParameters['from'].toString(),
            //         sub: 'record',
            //       )
            //     ),
            //   ]
            // ),
            GoRoute(
              path: 'credits',
              builder: (context, state) => Credits(),
              routes: [
                // GoRoute(
                //   path: 'credit',
                //   builder: (context, state) => CreditDetail(
                //     id: '',
                //     subIndex: -1,
                //     action: 'add',
                //     from: '',
                //     sub: 'credit',
                //   ),
                // ),
                // GoRoute(
                //   path: 'credit/:id',
                //   builder: (context, state) => CreditDetail(
                //     id: state.pathParameters['id']!,
                //     subIndex: -1,
                //     action: state.uri.queryParameters['action'].toString(),
                //     from: state.uri.queryParameters['from'].toString(),
                //     sub: 'credit',
                //   )
                // ),
              ]
            ),
            // GoRoute(
            //   path: 'budgets',
            //   builder: (context, state) => Budgets(),
            //   routes: [
            //     GoRoute(
            //       path: ':type/:id',
            //       builder: (context, state) => BudgetDetail(
            //         type: state.pathParameters['type']!,
            //         id: state.pathParameters['id']!,
            //         action: state.uri.queryParameters['action'].toString()
            //       ),
            //     )
            //   ]
            // ),
            GoRoute(
              path: 'transactions',
              builder: (context, state) => Transactions(),
              routes: [
                GoRoute(
                  path: 'transaction',
                  builder: (context, state) => TransactionDetail(
                    id: '',
                    action: 'add',
                    sub: 'transaction',
                  ),
                ),
                GoRoute(
                  path: 'transaction/:id',
                  builder: (context, state) => TransactionDetail(
                    id: state.pathParameters['id']!,
                    action: state.uri.queryParameters['action'].toString(),
                    sub: 'transaction',
                  ),
                ),
                // GoRoute(
                //   path: 'template',
                //   builder: (context, state) => TransactionDetail(
                //     id: '',
                //     action: 'add',
                //     sub: 'template',
                //   ),
                // ),
                // GoRoute(
                //   path: 'template/:id',
                //   builder: (context, state) => TransactionDetail(
                //     id: state.pathParameters['id']!,
                //     action: state.uri.queryParameters['action'].toString(),
                //     sub: 'template',
                //   ),
                // ),
                GoRoute(
                  path: 'plan',
                  builder: (context, state) => TransactionDetail(
                    id: '',
                    action: 'add',
                    sub: 'plan',
                  ),
                ),
                GoRoute(
                  path: 'plan/:id',
                  builder: (context, state) => TransactionDetail(
                    id: state.pathParameters['id']!,
                    action: state.uri.queryParameters['action'].toString(),
                    sub: 'plan',
                  ),
                )
              ]
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => Categories(),
              routes: [
                GoRoute(
                  path: 'category',
                  builder: (context, state) => CategoryDetail(
                    id: '',
                    subIndex: -1,
                    action: 'add',
                    from: '',
                    sub: 'category',
                  ),
                ),
                GoRoute(
                  path: 'category/:id',
                  builder: (context, state) => CategoryDetail(
                    id: state.pathParameters['id']!,
                    subIndex: -1,
                    action: state.uri.queryParameters['action'].toString(),
                    from: state.uri.queryParameters['from'].toString(),
                    sub: 'category',
                  )
                ),
                GoRoute(
                  path: 'category/:id/subcategory',
                  builder: (context, state) => CategoryDetail(
                    id: state.pathParameters['id']!,
                    subIndex: -1,
                    action: 'add',
                    from: '',
                    sub: 'subcategory',
                  ),
                ),
                GoRoute(
                  path: 'category/:id/subcategory/:subIndex',
                  builder: (context, state) => CategoryDetail(
                    id: state.pathParameters['id']!,
                    subIndex: int.parse(state.pathParameters['subIndex']!),
                    action: state.uri.queryParameters['action'].toString(),
                    from: state.uri.queryParameters['from'].toString(),
                    sub: 'subcategory',
                  )
                ),
              ]
            ),
            GoRoute(
              path: 'accounts',
              builder: (context, state) => Accounts(),
              routes: [
                GoRoute(
                  path: 'account',
                  builder: (context, state) => AccountDetail(
                    id: '',
                    action: 'add',
                    from: '',
                  ),
                ),
                GoRoute(
                  path: 'account/:id',
                  builder: (context, state) => AccountDetail(
                    id: state.pathParameters['id']!,
                    action: state.uri.queryParameters['action'].toString(),
                    from: state.uri.queryParameters['from'].toString(),
                  )
                ),
              ]
            ),
          ]
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => Analytics()
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => Account()
        ),
      ]
    )
  ]
);
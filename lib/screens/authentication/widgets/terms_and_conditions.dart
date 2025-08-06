import 'package:flutter/material.dart';

import '../../../utils/helpers/helper_function.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return AlertDialog(
      backgroundColor: dark ? Colors.black : Colors.white,
      title: const Text('Terms and Conditions'),
      content: SizedBox(
        height: 400,
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Text('''
1. Eligibility
You must be at least 18 years old and capable of entering into a binding contract.

2. Account Registration
Provide accurate and up-to-date info, and secure your credentials.

3. Platform Use
Use Vider lawfully. No spam, fraud, or abuse.

4. Provider & Client Responsibilities
Providers: Deliver on time, jobs are time sensitive.
Clients: Read and understand job descriptions of providers before hiring them.

5. Payments and Fees
Fees apply. Percentage cuts are taken from every job payment you receive. Review your subscription plan to choose the right plan.

6. Dispute Resolution
Contact support to resolve disputed cases.

7. Termination
Accounts may be suspended for violations.

8. Intellectual Property
Our content is protected. Don not copy or misuse it.

9. Changes
We may update these terms anytime. Continued use = acceptance.

10. Contact
Email: vider_support@gmail.com

By signing up, you agree to these terms.
''', style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text('Close',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red)),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicPageView extends StatefulWidget {
  final String slug;

  const DynamicPageView({super.key, required this.slug});

  @override
  State<DynamicPageView> createState() => _DynamicPageViewState();
}

class _DynamicPageViewState extends State<DynamicPageView> {
  Map contents = {
    'terms': {
      'title': 'شرایط استفاده',
      'content': '''
• برای استفاده از این برنامه، شما موافقت می‌کنید که:
• در صورت ارسال بیش از ۲۰ درخواست در یک دقیقه، دسترسی شما به صورت خودکار مسدود خواهد شد
• اطلاعات مکانی شما فقط برای یافتن نزدیک‌ترین سرویس‌های بهداشتی استفاده می‌شود
• از ارسال اطلاعات نادرست یا گمراه‌کننده خودداری کنید
• حق مسدود کردن کاربران متخلف برای ما محفوظ است''',
    },
    'privacy': {
      'title': 'حریم خصوصی',
      'content': '''
• ما به حریم خصوصی شما احترام می‌گذاریم
• موقعیت مکانی شما برای نمایش نزدیک‌ترین سرویس‌های بهداشتی استفاده می‌شود
• موقعیت مکانی شما برای پیدا کردن تبلیغ مخصوص شهر استفاده می‌شود
• از جایی که اپلیکیشن را نصب کرده اید و نسخه ای که دارید استفاده می‌کنید، برای بهبود خدمات استفاده می‌شود
• اطلاعات موقعیت مکانی شما در سرورهای ما ذخیره نمی‌شود
• ما هیچ اطلاعات شخصی را با اشخاص ثالث به اشتراک نمی‌گذاریم
• تمام ارتباطات به صورت رمزنگاری شده انجام می‌شود''',
    },
    'about': {
      'title': 'درباره ما',
      'content': '''
• هدف ما ارائه راه‌حلی آسان برای یافتن سرویس‌های بهداشتی در نزدیکی شماست
• ما متعهد به بهبود مداوم خدمات خود هستیم
• تیم ما با دقت تمام برای ارائه اطلاعات دقیق و به‌روز تلاش می‌کند
• از پیشنهادات و انتقادات شما برای بهبود خدمات استقبال می‌کنیم
• هدف ما ساخت اپلیکیشنی کاربردی و مفید برای تمام کاربران است''',
    },
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          contents[widget.slug]['title'],
          style: TextStyle(
            fontFamily: "YekanBakh",
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Text(
          contents[widget.slug]['content'],
          style: TextStyle(
            color: CupertinoColors.darkBackgroundGray,
          ),
        ),
      ),
    );
  }
}

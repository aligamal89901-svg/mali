# حالة المشروع — مالي | MALI

آخر تحديث: 2026-10-10 (إغلاق المرحلة الأولى)

## التقنية والإصدارات المعتمدة
- بيئة العمل: Termux على Android + Ubuntu عبر PRoot.
- Flutter: 3.44.7 (قناة stable) داخل Ubuntu.
- Dart: 3.12.2.
- Git: 2.56.0 في Termux، و2.53.0 داخل Ubuntu.
- المنصات المستهدفة: Android + Web (Web للتجربة أثناء التطوير).
- محرر الأكواد: Acode على الهاتف.

## مسارات المشروع
- المسار الأساسي في Termux: ~/mali
- مسار العمل داخل Ubuntu (عبر bind): /mnt/mali
  أمر الدخول: proot-distro login ubuntu --bind $HOME/mali:/mnt/mali
- نسخة قديمة متروكة داخل Ubuntu في ~/dev/mali — لا تُستخدم ولا تُحدَّث.

## المستودع والرفع
- المستودع: https://github.com/aligamal89901-svg/mali
- Remote: origin = git@github-aligamal:aligamal89901-svg/mali.git
- الفرع: main
- هوية Git: aligamal89901-svg / aligamal89901@gmail.com
- اسم اتصال SSH: github-aligamal (المفتاح ~/.ssh/id_ed25519_aligamal)

## المراحل المكتملة
- المرحلة 0 (تأسيس البيئة): مكتملة — فحص Termux وUbuntu، إنشاء مشروع mali، نسخه إلى Termux، نجاح flutter pub get، فتح المشروع في Acode.
- المرحلة 1 (مستودع GitHub): مكتملة — مستودع فارغ باسم mali، git init، ربط origin عبر SSH، رفع أول التزام ناجح تم التحقق منه من صفحة GitHub (commit 6cca952).

## المراحل التي لم تبدأ
- المرحلة 2: إعداد Flutter Web.
- المرحلة 3: الهوية والواجهة الرئيسية.
- المراحل 4 إلى 12: وفق خطة التنفيذ الإلزامية.

## القرارات الهندسية المهمة
- العمل مرحلة واحدة في كل مرة، مع التحقق قبل الانتقال.
- أوامر Flutter تُنفذ داخل Ubuntu (PRoot)، والتحرير في Termux عبر Acode.
- البناء النهائي لـ APK عبر GitHub Actions فقط، وليس بناء محليًا على الهاتف.
- قاعدة البيانات المحلية ستُختار عند المرحلة الرابعة (SQLite مع طبقة وصول منظمة، ويُقيَّم Drift حينها).
- إدارة الحالة ستُقيَّم وتُثبَّت عند الحاجة الفعلية، دون خلط أنظمة متعددة.

## الأخطاء التي ظهرت وأسبابها
- المسار $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/dev/mali غير موجود عند الفحص من Termux: سبب الوصول المختلف لملفات rootfs؛ الحل: ربط مجلد Termux عند الدخول (--bind) والنسخ من داخل التوزيعة.
- تحذير "running flutter as root" داخل PRoot: تحذير طبيعي في هذه البيئة ولا يؤثر على العمل.
- ملف التوثيق لم يصل إلى مسار المشروع عند إنشائه عبر Acode في المحاولة الأولى؛ الحل: إنشاؤه بأمر مباشر داخل Termux لضمان وصوله للمسار الصحيح.

## الاختبارات والنتائج الفعلية
- flutter pub get داخل /mnt/mali: نجح (Got dependencies!).
- git push الأول: نجح، وتم التحقق من وجود الملفات والالتزام من صفحة GitHub مباشرة (commit 6cca952).

## أوامر البناء والرفع المعتمدة
- الدخول لبيئة التطوير: proot-distro login ubuntu --bind $HOME/mali:/mnt/mali
- رفع التعديلات: git add . ثم git commit -m "وصف التغيير" ثم git push origin main

## المهام التالية
- المرحلة 2: التأكد من دعم الويب، تشغيل الواجهة في متصفح الهاتف للتطوير، معالجة أي أخطاء قبل الانتقال.

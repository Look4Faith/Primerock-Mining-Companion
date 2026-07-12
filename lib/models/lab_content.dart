class LabServiceItem {
  const LabServiceItem({
    required this.name,
    required this.description,
    this.turnaround,
  });

  final String name;
  final String description;
  final String? turnaround;

  factory LabServiceItem.fromJson(Map<String, dynamic> json) {
    return LabServiceItem(
      name: json['name'] as String,
      description: json['description'] as String,
      turnaround: json['turnaround'] as String?,
    );
  }
}

class WhyChooseItem {
  const WhyChooseItem({required this.title, required this.body});

  final String title;
  final String body;

  factory WhyChooseItem.fromJson(Map<String, dynamic> json) {
    return WhyChooseItem(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['description'] as String? ?? '',
    );
  }

  @override
  String toString() => title.isEmpty ? body : '$title — $body';
}

class ProcessStep {
  const ProcessStep({
    required this.step,
    required this.title,
    required this.description,
  });

  final int step;
  final String title;
  final String description;

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('title')) {
      return ProcessStep(
        step: (json['step'] as num?)?.toInt() ?? 0,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
      );
    }
    return ProcessStep(
      step: 0,
      title: json.values.first.toString(),
      description: '',
    );
  }
}

class LabFaq {
  const LabFaq({required this.question, required this.answer});

  final String question;
  final String answer;

  factory LabFaq.fromJson(Map<String, dynamic> json) {
    return LabFaq(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}

class LabContact {
  const LabContact({
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.address,
    required this.mapsQuery,
    this.hours,
  });

  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String mapsQuery;
  final String? hours;

  factory LabContact.fromJson(Map<String, dynamic> json) {
    return LabContact(
      phone: json['phone'] as String,
      whatsapp: json['whatsapp'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      mapsQuery: json['mapsQuery'] as String,
      hours: json['hours'] as String?,
    );
  }
}

class LabContent {
  const LabContent({
    required this.about,
    required this.whyChooseUs,
    required this.services,
    required this.processSteps,
    required this.faqs,
    required this.contact,
    this.tagline,
    this.companyName,
  });

  final String? companyName;
  final String? tagline;
  final String about;
  final List<WhyChooseItem> whyChooseUs;
  final List<LabServiceItem> services;
  final List<ProcessStep> processSteps;
  final List<LabFaq> faqs;
  final LabContact contact;

  factory LabContent.fromJson(Map<String, dynamic> json) {
    final whyRaw = json['whyChooseUs'] as List<dynamic>? ?? [];
    final why = whyRaw.map((e) {
      if (e is String) return WhyChooseItem(title: '', body: e);
      return WhyChooseItem.fromJson(e as Map<String, dynamic>);
    }).toList();

    final stepsRaw = json['processSteps'] as List<dynamic>? ?? [];
    final steps = stepsRaw.map((e) {
      if (e is String) {
        return ProcessStep(step: 0, title: e, description: '');
      }
      return ProcessStep.fromJson(e as Map<String, dynamic>);
    }).toList();

    return LabContent(
      companyName: json['companyName'] as String?,
      tagline: json['tagline'] as String?,
      about: json['about'] as String? ?? '',
      whyChooseUs: why,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => LabServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      processSteps: steps,
      faqs: (json['faqs'] as List<dynamic>? ?? [])
          .map((e) => LabFaq.fromJson(e as Map<String, dynamic>))
          .toList(),
      contact: LabContact.fromJson(
        json['contact'] as Map<String, dynamic>? ??
            {
              'phone': '+263771437248',
              'whatsapp': '+263771437248',
              'email': 'primerocksolutions@gmail.com',
              'address': '3 Milton Road, Fairbridge Park, Mutare, Zimbabwe',
              'mapsQuery': '3+Milton+Road+Fairbridge+Park+Mutare',
            },
      ),
    );
  }
}

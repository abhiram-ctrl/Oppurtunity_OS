import 'package:flutter/material.dart';
import '../models/opportunity.dart';

class SampleData {
  static final List<InternshipCategory> categories = [
    const InternshipCategory(
      id: 'ai_ml',
      name: 'AI / ML',
      emoji: '🤖',
      gradientColors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
      opportunityCount: 5,
    ),
    const InternshipCategory(
      id: 'data_science',
      name: 'Data Science',
      emoji: '📊',
      gradientColors: [Color(0xFF0061FF), Color(0xFF60EFFF)],
      opportunityCount: 5,
    ),
    const InternshipCategory(
      id: 'web_dev',
      name: 'Web Dev',
      emoji: '🌐',
      gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
      opportunityCount: 5,
    ),
    const InternshipCategory(
      id: 'mobile_dev',
      name: 'Mobile Dev',
      emoji: '📱',
      gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      opportunityCount: 5,
    ),
    const InternshipCategory(
      id: 'cloud_devops',
      name: 'Cloud / DevOps',
      emoji: '☁️',
      gradientColors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
      opportunityCount: 5,
    ),
    const InternshipCategory(
      id: 'cybersecurity',
      name: 'Cybersecurity',
      emoji: '🔐',
      gradientColors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      opportunityCount: 5,
    ),
  ];

  static final List<Opportunity> allOpportunities = [
    // ─── AI / ML ───────────────────────────────────────────────────────────────
    Opportunity(
      id: 'ai_1',
      company: 'Google DeepMind',
      companyEmoji: '🧠',
      role: 'AI Research Intern',
      summary:
          'Work alongside world-class researchers to advance the frontiers of AI and machine learning.',
      description:
          'Join Google DeepMind\'s research team to collaborate on cutting-edge AI projects. '
          'You will contribute to research papers, prototype novel algorithms, and work with large-scale '
          'datasets to push the boundaries of what\'s possible in artificial intelligence. '
          'Expect to be mentored by leading AI researchers and present findings to global teams.',
      deadline: DateTime(2026, 3, 14),
      applyLink: 'https://deepmind.google/careers',
      sources: ['gmail', 'linkedin'],
      category: 'ai_ml',
      location: 'London / Remote',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹1,20,000/mo',
      skills: ['Python', 'PyTorch', 'Research', 'ML Theory', 'Statistics'],
    ),
    Opportunity(
      id: 'ai_2',
      company: 'OpenAI',
      companyEmoji: '🤖',
      role: 'ML Engineering Intern',
      summary:
          'Build and optimize large-scale machine learning systems powering next-gen AI products.',
      description:
          'As an ML Engineering Intern at OpenAI, you\'ll work on systems that train and deploy frontier models. '
          'Responsibilities include optimizing training pipelines, building evaluation frameworks, '
          'and improving reliability of production AI systems. You\'ll collaborate with engineers '
          'and researchers shaping the future of AI.',
      deadline: DateTime(2026, 3, 15),
      applyLink: 'https://openai.com/careers',
      sources: ['gmail', 'whatsapp'],
      category: 'ai_ml',
      location: 'San Francisco / Hybrid',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,50,000/mo',
      skills: ['Python', 'CUDA', 'Distributed Systems', 'PyTorch', 'Triton'],
    ),
    Opportunity(
      id: 'ai_3',
      company: 'Microsoft Research',
      companyEmoji: '🔬',
      role: 'AI/ML Intern',
      summary:
          'Contribute to applied AI research focusing on natural language understanding and vision.',
      description:
          'Microsoft Research offers a unique internship that blends academic research with real-world product impact. '
          'Interns collaborate on projects spanning NLP, computer vision, and reinforcement learning. '
          'You\'ll publish research, prototype solutions, and present to leadership across Microsoft.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://careers.microsoft.com/research',
      sources: ['gmail'],
      category: 'ai_ml',
      location: 'Bangalore / Remote',
      duration: '4 Months',
      isPaid: true,
      stipend: '₹90,000/mo',
      skills: ['Python', 'TensorFlow', 'NLP', 'Azure ML', 'Research Writing'],
    ),
    Opportunity(
      id: 'ai_4',
      company: 'Meta AI',
      companyEmoji: '👾',
      role: 'Computer Vision Intern',
      summary:
          'Develop advanced computer vision models for AR/VR and social media applications.',
      description:
          'Meta AI is looking for passionate computer vision interns to work on projects ranging from '
          'real-time video understanding to 3D scene reconstruction. You\'ll work with state-of-the-art '
          'hardware, massive datasets, and a team building the future of the metaverse.',
      deadline: DateTime(2026, 3, 22),
      applyLink: 'https://ai.meta.com/careers',
      sources: ['linkedin', 'gmail'],
      category: 'ai_ml',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,05,000/mo',
      skills: ['Python', 'PyTorch', 'Computer Vision', 'OpenCV', 'CUDA'],
    ),
    Opportunity(
      id: 'ai_5',
      company: 'NVIDIA',
      companyEmoji: '🟢',
      role: 'Deep Learning Intern',
      summary:
          'Optimize deep learning workloads on NVIDIA GPUs and contribute to the cuDNN library.',
      description:
          'Join NVIDIA\'s Deep Learning team to work on performance optimization of neural network training. '
          'You\'ll profile GPU kernels, implement CUDA optimizations, and contribute to frameworks '
          'trusted by millions of AI practitioners globally.',
      deadline: DateTime(2026, 4, 1),
      applyLink: 'https://nvidia.com/careers',
      sources: ['whatsapp', 'gmail'],
      category: 'ai_ml',
      location: 'Pune / Remote',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹80,000/mo',
      skills: ['CUDA', 'C++', 'Python', 'Deep Learning', 'GPU Architecture'],
    ),

    // ─── Data Science ──────────────────────────────────────────────────────────
    Opportunity(
      id: 'ds_1',
      company: 'Netflix',
      companyEmoji: '🎬',
      role: 'Data Science Intern',
      summary:
          'Build recommendation algorithms and A/B testing frameworks used by 270M+ subscribers.',
      description:
          'Netflix Data Science internship places you at the heart of the world\'s leading streaming platform. '
          'You\'ll develop models that personalize content for hundreds of millions of users, '
          'run causal inference experiments, and produce insights that drive product decisions.',
      deadline: DateTime(2026, 3, 14),
      applyLink: 'https://jobs.netflix.com',
      sources: ['gmail', 'linkedin'],
      category: 'data_science',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,10,000/mo',
      skills: ['Python', 'SQL', 'Spark', 'Causal Inference', 'Statistics'],
    ),
    Opportunity(
      id: 'ds_2',
      company: 'Airbnb',
      companyEmoji: '🏠',
      role: 'Analytics Engineering Intern',
      summary:
          'Design data pipelines and dashboards that inform pricing and trust & safety decisions.',
      description:
          'Airbnb\'s data platform team is seeking an intern to help build scalable analytics infrastructure. '
          'You\'ll work with petabyte-scale data, build dbt models, create Looker dashboards, '
          'and collaborate with product and engineering teams to surface actionable insights.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://careers.airbnb.com',
      sources: ['gmail'],
      category: 'data_science',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹95,000/mo',
      skills: ['SQL', 'dbt', 'Python', 'Looker', 'Data Modeling'],
    ),
    Opportunity(
      id: 'ds_3',
      company: 'Spotify',
      companyEmoji: '🎵',
      role: 'Data Science Intern – Music Intelligence',
      summary:
          'Apply ML to audio features and user behavior to improve music discovery at scale.',
      description:
          'Spotify\'s Music Intelligence team is revolutionizing how listeners discover music. '
          'As an intern, you\'ll work on recommendation systems, build audio feature extractors, '
          'and run large-scale experiments that directly impact product personalization.',
      deadline: DateTime(2026, 3, 19),
      applyLink: 'https://spotify.com/careers',
      sources: ['whatsapp', 'gmail'],
      category: 'data_science',
      location: 'Stockholm / Remote',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹85,000/mo',
      skills: ['Python', 'SQL', 'Recommender Systems', 'NLP', 'PySpark'],
    ),
    Opportunity(
      id: 'ds_4',
      company: 'Amazon',
      companyEmoji: '📦',
      role: 'Business Intelligence Intern',
      summary:
          'Create self-serve data tools and forecasting models for Amazon\'s supply chain.',
      description:
          'Amazon\'s supply chain analytics team needs an intern to build BI tools and forecasting models '
          'that optimize inventory and logistics decisions across 20+ countries. '
          'You\'ll use Redshift, QuickSight, and SageMaker to drive operational efficiency.',
      deadline: DateTime(2026, 3, 27),
      applyLink: 'https://amazon.jobs',
      sources: ['linkedin'],
      category: 'data_science',
      location: 'Hyderabad / Hybrid',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹70,000/mo',
      skills: ['SQL', 'Python', 'AWS', 'QuickSight', 'Forecasting'],
    ),
    Opportunity(
      id: 'ds_5',
      company: 'Zomato',
      companyEmoji: '🍕',
      role: 'Data Analyst Intern',
      summary:
          'Analyze order, delivery, and restaurant data to improve hyperlocal customer experiences.',
      description:
          'Zomato\'s data team is looking for a driven intern to dive into rich behavioral datasets. '
          'You\'ll segment customers, identify growth opportunities, and build dashboards '
          'that guide product and marketing decisions across 800+ cities in India.',
      deadline: DateTime(2026, 4, 5),
      applyLink: 'https://zomato.com/careers',
      sources: ['whatsapp', 'gmail'],
      category: 'data_science',
      location: 'Gurugram / Hybrid',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹40,000/mo',
      skills: ['SQL', 'Python', 'Tableau', 'Excel', 'Growth Analytics'],
    ),

    // ─── Web Development ───────────────────────────────────────────────────────
    Opportunity(
      id: 'web_1',
      company: 'Shopify',
      companyEmoji: '🛍️',
      role: 'Frontend Engineering Intern',
      summary:
          'Build and ship UI features impacting millions of merchants across the Shopify admin.',
      description:
          'As a Frontend Engineering Intern at Shopify, you\'ll own and ship real product features '
          'used by millions of merchants globally. You\'ll work with React, GraphQL, and Polaris design system, '
          'participate in code reviews, and collaborate with designers to deliver delightful UIs.',
      deadline: DateTime(2026, 3, 15),
      applyLink: 'https://shopify.com/careers',
      sources: ['gmail', 'linkedin'],
      category: 'web_dev',
      location: 'Remote',
      duration: '4 Months',
      isPaid: true,
      stipend: '₹1,00,000/mo',
      skills: ['React', 'TypeScript', 'GraphQL', 'CSS', 'Testing'],
    ),
    Opportunity(
      id: 'web_2',
      company: 'Stripe',
      companyEmoji: '💳',
      role: 'Full Stack Intern',
      summary:
          'Build developer-facing APIs and dashboards that power the global payments infrastructure.',
      description:
          'Stripe\'s internship is one of the most coveted in tech. You\'ll work on full-stack features '
          'across Ruby on Rails, React, and Go that handle trillions of dollars in payments. '
          'Expect high ownership, fast feedback cycles, and mentorship from senior engineers.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://stripe.com/jobs',
      sources: ['gmail'],
      category: 'web_dev',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,30,000/mo',
      skills: ['Ruby on Rails', 'React', 'PostgreSQL', 'Go', 'API Design'],
    ),
    Opportunity(
      id: 'web_3',
      company: 'Vercel',
      companyEmoji: '▲',
      role: 'Developer Experience Intern',
      summary:
          'Improve documentation, SDKs, and tooling for the Next.js and Vercel ecosystem.',
      description:
          'Vercel is seeking a Developer Experience Intern to make it easier for developers worldwide '
          'to build and deploy web apps. You\'ll work on Next.js examples, SDK improvements, '
          'CLI tooling, and technical content that helps millions of developers succeed.',
      deadline: DateTime(2026, 3, 22),
      applyLink: 'https://vercel.com/careers',
      sources: ['whatsapp', 'gmail'],
      category: 'web_dev',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹90,000/mo',
      skills: [
        'Next.js',
        'React',
        'TypeScript',
        'Node.js',
        'Technical Writing',
      ],
    ),
    Opportunity(
      id: 'web_4',
      company: 'GitHub',
      companyEmoji: '🐙',
      role: 'Web Engineering Intern',
      summary:
          'Contribute to GitHub.com features used by 100M+ developers worldwide.',
      description:
          'GitHub is looking for a passionate web engineering intern to work on github.com. '
          'You\'ll build accessible, performant UI components using Rails, React, and Primer design system, '
          'fix real bugs, and ship features to developers around the globe.',
      deadline: DateTime(2026, 3, 27),
      applyLink: 'https://github.com/about/careers',
      sources: ['linkedin', 'gmail'],
      category: 'web_dev',
      location: 'Remote',
      duration: '4 Months',
      isPaid: true,
      stipend: '₹1,10,000/mo',
      skills: ['Ruby on Rails', 'React', 'GraphQL', 'Accessibility', 'Git'],
    ),
    Opportunity(
      id: 'web_5',
      company: 'Razorpay',
      companyEmoji: '⚡',
      role: 'UI Engineer Intern',
      summary:
          'Design and develop fintech UI components for India\'s leading payments platform.',
      description:
          'Razorpay\'s frontend team is looking for a talented intern to build UI components '
          'and improve the merchant dashboard experience. You\'ll work with Vue.js, '
          'build reusable design system components, and collaborate closely with product and UX.',
      deadline: DateTime(2026, 4, 2),
      applyLink: 'https://razorpay.com/jobs',
      sources: ['whatsapp'],
      category: 'web_dev',
      location: 'Bangalore / Hybrid',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹50,000/mo',
      skills: ['Vue.js', 'JavaScript', 'CSS', 'Figma', 'REST APIs'],
    ),

    // ─── Mobile Development ────────────────────────────────────────────────────
    Opportunity(
      id: 'mob_1',
      company: 'Apple',
      companyEmoji: '🍎',
      role: 'iOS Engineering Intern',
      summary:
          'Build native iOS features shipped to billions of Apple devices worldwide.',
      description:
          'Apple\'s iOS team is seeking exceptional engineering interns to work on core iOS frameworks '
          'and user-facing features. You\'ll use Swift, SwiftUI, and UIKit to build polished experiences '
          'shipped to over a billion devices. Expect world-class mentorship and unparalleled scale.',
      deadline: DateTime(2026, 3, 14),
      applyLink: 'https://apple.com/careers',
      sources: ['gmail', 'linkedin'],
      category: 'mobile_dev',
      location: 'Cupertino / Hybrid',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,40,000/mo',
      skills: ['Swift', 'SwiftUI', 'UIKit', 'Core Data', 'Xcode'],
    ),
    Opportunity(
      id: 'mob_2',
      company: 'WhatsApp',
      companyEmoji: '💬',
      role: 'Android Intern',
      summary:
          'Improve WhatsApp\'s Android app for 2B+ users across privacy and messaging features.',
      description:
          'WhatsApp\'s Android team is hiring interns to work on features experienced by 2 billion users. '
          'You\'ll use Kotlin, Jetpack Compose, and Android SDK to build high-performance messaging features, '
          'improve end-to-end encryption flows, and optimize app startup and memory.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://careers.whatsapp.com',
      sources: ['whatsapp', 'gmail'],
      category: 'mobile_dev',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,00,000/mo',
      skills: [
        'Kotlin',
        'Jetpack Compose',
        'Android SDK',
        'MVVM',
        'Coroutines',
      ],
    ),
    Opportunity(
      id: 'mob_3',
      company: 'Snap Inc.',
      companyEmoji: '👻',
      role: 'Flutter Developer Intern',
      summary:
          'Build cross-platform creative tools in Flutter for the Snapchat creator ecosystem.',
      description:
          'Snap\'s creator tools team is looking for a Flutter engineer intern to build '
          'high-performance cross-platform features for Snapchat. You\'ll work on camera effects, '
          'AR features, and creative tools that millions of users interact with daily.',
      deadline: DateTime(2026, 3, 19),
      applyLink: 'https://careers.snap.com',
      sources: ['gmail'],
      category: 'mobile_dev',
      location: 'Remote',
      duration: '4 Months',
      isPaid: true,
      stipend: '₹90,000/mo',
      skills: ['Flutter', 'Dart', 'Firebase', 'AR', 'Camera APIs'],
    ),
    Opportunity(
      id: 'mob_4',
      company: 'PhonePe',
      companyEmoji: '📲',
      role: 'Mobile Engineering Intern',
      summary:
          'Build UPI and fintech features for one of India\'s fastest-growing payment super-apps.',
      description:
          'PhonePe is India\'s leading digital payments platform. As a mobile intern, you\'ll work on '
          'Android and React Native features across payments, insurance, and investments. '
          'You\'ll ship real code to millions of users in an agile, high-velocity environment.',
      deadline: DateTime(2026, 3, 22),
      applyLink: 'https://phonepe.com/careers',
      sources: ['whatsapp', 'gmail'],
      category: 'mobile_dev',
      location: 'Bangalore / Hybrid',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹60,000/mo',
      skills: ['React Native', 'Android', 'Kotlin', 'Redux', 'REST APIs'],
    ),
    Opportunity(
      id: 'mob_5',
      company: 'Samsung R&D',
      companyEmoji: '📱',
      role: 'Mobile UX Intern',
      summary:
          'Design and prototype next-generation mobile interactions for Samsung Galaxy devices.',
      description:
          'Samsung\'s R&D institute in Bangalore is looking for a Mobile UX Intern with coding skills '
          'to prototype and build innovative UI experiments for Galaxy smartphones. '
          'You\'ll work on gesture-based navigation, AI-driven interfaces, and hardware-software integration.',
      deadline: DateTime(2026, 4, 1),
      applyLink: 'https://samsung.com/sribd/careers',
      sources: ['linkedin'],
      category: 'mobile_dev',
      location: 'Bangalore',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹50,000/mo',
      skills: ['Android', 'Java', 'Kotlin', 'UI Prototyping', 'UX Research'],
    ),

    // ─── Cloud / DevOps ────────────────────────────────────────────────────────
    Opportunity(
      id: 'cloud_1',
      company: 'AWS',
      companyEmoji: '☁️',
      role: 'Cloud Engineering Intern',
      summary:
          'Build and operate services running on the world\'s largest cloud infrastructure.',
      description:
          'Amazon Web Services is offering an internship where you\'ll work on real AWS services '
          'used by millions of customers. You\'ll contribute to infrastructure automation, '
          'build internal tools, write CloudFormation templates, and improve observability pipelines.',
      deadline: DateTime(2026, 3, 15),
      applyLink: 'https://amazon.jobs/aws',
      sources: ['gmail', 'linkedin'],
      category: 'cloud_devops',
      location: 'Hyderabad / Hybrid',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹90,000/mo',
      skills: ['AWS', 'Terraform', 'Python', 'CloudFormation', 'Linux'],
    ),
    Opportunity(
      id: 'cloud_2',
      company: 'Google Cloud',
      companyEmoji: '🌩️',
      role: 'SRE Intern',
      summary:
          'Improve the reliability, scalability, and efficiency of Google Cloud\'s global infrastructure.',
      description:
          'Google Cloud\'s SRE team is hiring an intern to work on monitoring, alerting, and automation '
          'systems. You\'ll analyze incident postmortems, build runbooks, and implement automated '
          'remediation to improve the reliability of services running at Google scale.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://cloud.google.com/jobs',
      sources: ['gmail'],
      category: 'cloud_devops',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,20,000/mo',
      skills: ['GCP', 'Kubernetes', 'Go', 'Prometheus', 'Python'],
    ),
    Opportunity(
      id: 'cloud_3',
      company: 'HashiCorp',
      companyEmoji: '🔷',
      role: 'DevOps Engineering Intern',
      summary:
          'Contribute to Terraform and Vault – the tools that define modern infrastructure as code.',
      description:
          'HashiCorp is the company behind Terraform, Vault, Consul, and Nomad. '
          'As a DevOps intern, you\'ll contribute to open-source tooling, write Go code, '
          'improve CI/CD pipelines, and help the community adopt infrastructure as code practices.',
      deadline: DateTime(2026, 3, 22),
      applyLink: 'https://hashicorp.com/jobs',
      sources: ['whatsapp', 'gmail'],
      category: 'cloud_devops',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹85,000/mo',
      skills: ['Go', 'Terraform', 'Kubernetes', 'Docker', 'CI/CD'],
    ),
    Opportunity(
      id: 'cloud_4',
      company: 'DigitalOcean',
      companyEmoji: '🐳',
      role: 'Platform Engineering Intern',
      summary:
          'Help simplify cloud infrastructure for developers and small businesses worldwide.',
      description:
          'DigitalOcean makes cloud computing simple for developers. As a platform intern, '
          'you\'ll work on Kubernetes orchestration, improve the developer control panel, '
          'build automation tooling, and contribute to infrastructure that powers millions of apps.',
      deadline: DateTime(2026, 3, 27),
      applyLink: 'https://digitalocean.com/careers',
      sources: ['linkedin'],
      category: 'cloud_devops',
      location: 'Remote',
      duration: '4 Months',
      isPaid: true,
      stipend: '₹75,000/mo',
      skills: ['Kubernetes', 'Docker', 'Python', 'Bash', 'Ansible'],
    ),
    Opportunity(
      id: 'cloud_5',
      company: 'Infosys',
      companyEmoji: '🏢',
      role: 'DevOps Trainee',
      summary:
          'Learn CI/CD, containerization, and cloud deployment in a structured enterprise program.',
      description:
          'Infosys offers a comprehensive DevOps internship covering Docker, Kubernetes, Jenkins, '
          'and Azure DevOps. You\'ll work on live client projects, participate in agile sprints, '
          'and earn industry-recognized certifications upon completion.',
      deadline: DateTime(2026, 4, 10),
      applyLink: 'https://infosys.com/careers',
      sources: ['whatsapp'],
      category: 'cloud_devops',
      location: 'Pune / Bangalore',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹25,000/mo',
      skills: ['Docker', 'Jenkins', 'Azure', 'Linux', 'Shell Scripting'],
    ),

    // ─── Cybersecurity ─────────────────────────────────────────────────────────
    Opportunity(
      id: 'sec_1',
      company: 'CrowdStrike',
      companyEmoji: '🦅',
      role: 'Security Research Intern',
      summary:
          'Hunt for advanced threats and analyze malware targeting Fortune 500 companies.',
      description:
          'CrowdStrike\'s Falcon Intelligence team is looking for a security research intern with '
          'a passion for threat hunting and malware analysis. You\'ll reverse engineer malware, '
          'write detection rules, and contribute to threat intelligence reports consumed by global SOC teams.',
      deadline: DateTime(2026, 3, 14),
      applyLink: 'https://crowdstrike.com/careers',
      sources: ['gmail', 'linkedin'],
      category: 'cybersecurity',
      location: 'Remote',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹1,05,000/mo',
      skills: [
        'Reverse Engineering',
        'Python',
        'YARA',
        'Malware Analysis',
        'IDA Pro',
      ],
    ),
    Opportunity(
      id: 'sec_2',
      company: 'Palo Alto Networks',
      companyEmoji: '🛡️',
      role: 'Cybersecurity Intern',
      summary:
          'Work on next-gen firewall and SIEM solutions protecting enterprise networks globally.',
      description:
          'Palo Alto Networks is pioneering network security. As an intern, you\'ll work on '
          'detection engineering, build SOAR automation playbooks, and help improve the Cortex XSOAR platform '
          'used by thousands of enterprise security teams worldwide.',
      deadline: DateTime(2026, 3, 17),
      applyLink: 'https://paloaltonetworks.com/careers',
      sources: ['gmail'],
      category: 'cybersecurity',
      location: 'Remote',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹95,000/mo',
      skills: ['SIEM', 'Python', 'SOAR', 'Network Security', 'Threat Analysis'],
    ),
    Opportunity(
      id: 'sec_3',
      company: 'IBM Security',
      companyEmoji: '🔵',
      role: 'Ethical Hacking Intern',
      summary:
          'Perform penetration tests and red team exercises for IBM\'s enterprise clients.',
      description:
          'IBM\'s X-Force Red team conducts offensive security assessments for global organizations. '
          'As an intern, you\'ll participate in web app pentests, network assessments, and social engineering simulations. '
          'Prepare detailed reports and recommendations that improve client security posture.',
      deadline: DateTime(2026, 3, 19),
      applyLink: 'https://ibm.com/careers/security',
      sources: ['whatsapp', 'gmail'],
      category: 'cybersecurity',
      location: 'Bangalore / Hybrid',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹65,000/mo',
      skills: [
        'Penetration Testing',
        'Burp Suite',
        'Metasploit',
        'Linux',
        'Report Writing',
      ],
    ),
    Opportunity(
      id: 'sec_4',
      company: 'Cisco',
      companyEmoji: '🌀',
      role: 'Network Security Intern',
      summary:
          'Design and test network security architectures for Cisco\'s enterprise product line.',
      description:
          'Cisco\'s security team is looking for an intern to work on next-gen firewall configurations, '
          'network intrusion detection, and zero-trust architecture implementations. '
          'You\'ll work with Cisco SecureX, Umbrella, and Firepower products in real enterprise environments.',
      deadline: DateTime(2026, 3, 27),
      applyLink: 'https://jobs.cisco.com',
      sources: ['linkedin', 'gmail'],
      category: 'cybersecurity',
      location: 'Bangalore',
      duration: '6 Months',
      isPaid: true,
      stipend: '₹55,000/mo',
      skills: ['Cisco IOS', 'Firewall', 'VPN', 'Network Protocols', 'Python'],
    ),
    Opportunity(
      id: 'sec_5',
      company: 'Razorpay Security',
      companyEmoji: '🔒',
      role: 'AppSec Intern',
      summary:
          'Secure fintech applications by conducting code reviews and threat modeling exercises.',
      description:
          'Razorpay\'s Application Security team is hiring an intern to perform SAST, DAST, '
          'and threat modeling on payment APIs handling billions of rupees daily. '
          'You\'ll integrate security into CI/CD, write secure coding guidelines, and train developers.',
      deadline: DateTime(2026, 4, 5),
      applyLink: 'https://razorpay.com/jobs/security',
      sources: ['whatsapp'],
      category: 'cybersecurity',
      location: 'Bangalore / Hybrid',
      duration: '3 Months',
      isPaid: true,
      stipend: '₹50,000/mo',
      skills: ['OWASP', 'Burp Suite', 'Python', 'SAST/DAST', 'Threat Modeling'],
    ),
  ];

  static List<Opportunity> getByCategory(String categoryId) {
    return allOpportunities.where((o) => o.category == categoryId).toList();
  }

  static List<Opportunity> getUrgentOpportunities() {
    return allOpportunities
        .where((o) => o.daysLeft > 0 && o.daysLeft <= 7)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  }

  static List<Opportunity> getAllSorted() {
    final list = List<Opportunity>.from(allOpportunities);
    list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }
}

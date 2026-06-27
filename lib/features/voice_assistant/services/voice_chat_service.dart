import 'dart:async';

class VoiceChatService {
  Future<String> sendMessage(String message) async {
    // Simulate network delay to demonstrate the 'thinking' state
    await Future.delayed(const Duration(milliseconds: 1500));

    final text = message.toLowerCase().trim();

    if (text.contains('headache')) {
      return "I understand. Persistent headaches can have many causes. Please consult a doctor if the pain is severe or persistent.";
    }

    if (text.contains('emergency') || text.contains('allerg')) {
      return "I can open your emergency card with allergies, blood group, emergency contacts, and critical medicines. For an urgent medical emergency, call local emergency services now.";
    }

    if (text.contains('medicine') || text.contains('medication') || text.contains('pill')) {
      return "You have two evening medicines due at 8:00 PM: Metformin 500 mg and Atorvastatin 20 mg. I can open your medication schedule.";
    }

    if (text.contains('record') || text.contains('report') || text.contains('result')) {
      return "Your vault contains lab, prescription, radiology, and vaccine records. I can open it so you can search or share a record.";
    }

    if (text.contains('upload') || text.contains('scan')) {
      return "I can take you to Upload, where you can scan a report, choose an image, or select a PDF.";
    }

    if (text.contains('family') || text.contains('robert') || text.contains('member')) {
      return "I can open your family profiles. Robert has a blood-pressure check due today.";
    }

    if (text.contains('timeline') || text.contains('history')) {
      return "I can open your health timeline and filter visits, reports, medicines, and vaccines.";
    }

    // Default response
    return "I can help you find records, review today's medicines, upload a report, open family profiles, or show emergency information. I do not diagnose conditions or replace a clinician. How else can I help you, Sarah?";
  }
}

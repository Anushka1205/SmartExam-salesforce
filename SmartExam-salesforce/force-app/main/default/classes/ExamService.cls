public with sharing class ExamService {

    // Starts a new exam attempt
    public static Id startExam(String studentName, String studentEmail) {

        validateExamConfiguration();

        Exam_Config__c examConfig = getActiveExamConfig();

        Exam_Attempt__c examAttempt = new Exam_Attempt__c(
            Student_Name__c = studentName,
            Student_Email__c = studentEmail,
            Start_Time__c = System.now(),
            Status__c = 'In Progress',
            Exam_Config__c = examConfig.Id
        );

        insert examAttempt;

        return examAttempt.Id;
    }

    // Returns an existing exam attempt
    public static Exam_Attempt__c getExamAttempt(Id attemptId) {

        return [
            SELECT Id,
                   Student_Name__c,
                   Student_Email__c,
                   Start_Time__c,
                   End_Time__c,
                   Score__c,
                   Status__c,
                   Exam_Config__c
            FROM Exam_Attempt__c
            WHERE Id = :attemptId
            LIMIT 1
        ];
    }

    // Returns the active exam configuration
    public static Exam_Config__c getActiveExamConfig() {

        List<Exam_Config__c> examConfigs = [
            SELECT Id,
                   Name,
                   Duration_Minutes__c,
                   Number_of_Questions__c,
                   Passing_Percentage__c,
                   Active__c
            FROM Exam_Config__c
            WHERE Active__c = true
            LIMIT 1
        ];

        if (examConfigs.isEmpty()) {
            throw new AuraHandledException('No active exam configuration found.');
        }

        return examConfigs[0];
    }

    // Validates the exam configuration
    public static void validateExamConfiguration() {

        Exam_Config__c examConfig = getActiveExamConfig();

        Integer activeQuestionCount =
            QuestionService.getActiveQuestionCount();

        if (activeQuestionCount < examConfig.Number_of_Questions__c) {

            throw new AuraHandledException(
                'Not enough active questions available for this exam.'
            );

        }
    }

    /*
     * Saves the student's selected responses.
     * Existing responses for the attempt are removed and replaced.
     */
    @AuraEnabled
    public static void saveResponses(
        Id examAttemptId,
        List<Response__c> responses
    ) {

        if (examAttemptId == null) {
            throw new AuraHandledException('Exam Attempt Id is required.');
        }

        if (responses == null || responses.isEmpty()) {
            return;
        }

        // Delete previous responses
        List<Response__c> existingResponses = [
            SELECT Id
            FROM Response__c
            WHERE Exam_Attempt__c = :examAttemptId
        ];

        if (!existingResponses.isEmpty()) {
            delete existingResponses;
        }

        // Assign Exam Attempt to every response
        for (Response__c response : responses) {

            response.Exam_Attempt__c = examAttemptId;
            response.Is_Selected__c = true;
        }

        insert responses;
    }

}
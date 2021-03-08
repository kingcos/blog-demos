import Foundation

// 18. 表驱动法

// 消息数据类型
enum FieldType {
    case floatingPoint
    case integer
    case string
    case timeOfDay
    case boolean
    case bitField
}

enum FileStatus {
    case ok
    case no
}

struct Field {
    var fieldType: FieldType
    var fieldName: String
}

// 对象模型
protocol AbstractField {
    func readAndPrint(_ content: String, _ fileStatus: FileStatus)
}

struct FloatingPointField : AbstractField {
    func readAndPrint(_ content: String, _ fileStatus: FileStatus) {
        print("FloatingPoint - \(content)")
    }
}

struct IntegerField : AbstractField {
    func readAndPrint(_ content: String, _ fileStatus: FileStatus) {
        print("Integer - \(content)")
    }
}

// ...

// 消息表
let fieldDescription: [Int : Field] = [
    1 : Field(fieldType: .floatingPoint, fieldName: "平均温度"),
    2 : Field(fieldType: .floatingPoint, fieldName: "温度范围"),
    3 : Field(fieldType: .integer,       fieldName: "采样点数"),
    4 : Field(fieldType: .string,        fieldName: "位置"),
    5 : Field(fieldType: .timeOfDay,     fieldName: "测量时间"),
]

// 对象清单
let fields: [FieldType : AbstractField] = [
    .floatingPoint : FloatingPointField(),
    .integer       : IntegerField()
]

// 查询

var fieldIdx = 1
let numFieldsInMessage = 5
let fileStatus = FileStatus.ok

while fieldIdx < numFieldsInMessage && fileStatus == .ok {
    let fieldType = fieldDescription[fieldIdx]!.fieldType
    let fieldName = fieldDescription[fieldIdx]!.fieldName
    
    fields[fieldType]?.readAndPrint(fieldName, fileStatus)
    
    fieldIdx += 1;
}


// OUTPUT
// FloatingPoint - 平均温度
// FloatingPoint - 温度范围
// Integer - 采样点数

// -----
print("-----")
// -----

func calculateStudentGrade(_ studentScore: Double) -> String {
    let rangeLimit = [50.0, 65.0, 75.0, 90.0, 100.0]
    let grade = ["F", "D", "C", "B", "A"]

    let maxGradeLevel = grade.count - 1

    var gradeLevel = 0
    var studentGrade = "A"

    while gradeLevel < maxGradeLevel {
        if studentScore < rangeLimit[gradeLevel] {
            studentGrade = grade[gradeLevel]
        }
        
        gradeLevel += 1
    }
    
    return studentGrade
}

print("studentGrade -", calculateStudentGrade(81))

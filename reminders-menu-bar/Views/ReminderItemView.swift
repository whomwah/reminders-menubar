import SwiftUI
import EventKit

struct ReminderItemView: View {
    @State var reminder: EKReminder
    var reload: () -> Void
    
    var body: some View {
        HStack (alignment: .top) {
            Button(action: {
                self.reminder.isCompleted.toggle()
                RemindersService.instance.save(reminder: self.reminder)
                self.reload()
            }) {
                Image(self.reminder.isCompleted ? "circle.filled" : "circle")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(.top, 1)
                    .foregroundColor(Color(reminder.calendar.color))
            }.buttonStyle(PlainButtonStyle())
            VStack {
                HStack {
                    Text(reminder.title)
                    Spacer()
                    Button(action: {
                        RemindersService.instance.remove(reminder: self.reminder)
                        self.reload()
                    }) {
                        Image("ellipsis")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.top, 1)
                            .padding(.trailing, 10)
                            .foregroundColor(.gray)
                    }.buttonStyle(PlainButtonStyle())
                }
                Spacer()
                Divider()
            }
        }
    }
}

//struct ReminderItemView_Previews: PreviewProvider {
//    static var previews: some View {
////        ReminderItemView()
//    }
//}
import SwiftUI

struct PreviousAnswerView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Text("Zaman Kapsülü")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.questionTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Previous Answers
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.previousYearAnswers) { answer in
                            VStack(alignment: .leading, spacing: 12) {
                                // Date
                                HStack {
                                    Text("\(Calendar.current.component(.year, from: answer.date)) yılı")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    if answer.isFavorite {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                
                                // Answer Text
                                Text(answer.text)
                                    .font(.body)
                                    .padding()
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PreviousAnswerView(viewModel: MainViewModel())
}

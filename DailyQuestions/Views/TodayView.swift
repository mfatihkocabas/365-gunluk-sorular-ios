import SwiftUI

struct TodayViewExact: View {
    @StateObject private var viewModel = MainViewModel()
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        // Test için geçici tarih: Bugünün tarihi
        let testDate = Date()
        return formatter.string(from: testDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Area - Krem renk
            VStack(spacing: 0) {
                // Navigation Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Günün Sorusu")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color(red: 0.95, green: 0.94, blue: 0.90)) // Krem renk
                
                // Date - Bold ve gerçek tarih
                Text(currentDateString)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                // Main Question
                Text(viewModel.questionTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 15)
            }
            .background(Color(red: 0.95, green: 0.94, blue: 0.90)) // Krem renk
            
            // Content Area - Gri arka plan
            VStack(spacing: 0) {
                // Text Editor Area - Küçültülmüş
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        // Açık krem background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.99, green: 0.98, blue: 0.96))
                            .frame(height: 140) // Tasarıma uygun boyut
                        
                        // Text Editor veya Today's Answer Display
                        if viewModel.hasAnsweredToday {
                            // Bugün cevap verilmiş - Güzel card design
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                    
                                    Text("Bugünkü Cevabınız")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                Text(viewModel.answerText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(nil)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                            .padding(.horizontal, 4)
                        } else {
                            // Henüz cevap verilmemiş - Güzel yazma alanı
                            VStack(spacing: 0) {
                                if viewModel.answerText.isEmpty {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.gray.opacity(0.6))
                                            .font(.system(size: 14))
                                        
                                        Text("Düşüncelerinizi paylaşın...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray.opacity(0.6))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                }
                                
                                TextEditor(text: $viewModel.answerText)
                                    .font(.system(size: 16))
                                    .frame(height: 90)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color.clear)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Buttons Area
                HStack {
                    // Favorite Button - Only show when writing (not answered today)
                    if !viewModel.hasAnsweredToday {
                        Button(action: {
                            viewModel.toggleFavorite()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                                
                                Text("Favorilere Ekle")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .gray.opacity(0.15), radius: 2, x: 0, y: 1)
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Save Button - Only show if not answered today
                    if !viewModel.hasAnsweredToday {
                        Button(action: {
                            viewModel.saveAnswer()
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.gray)
                                    .cornerRadius(16)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("Kaydet")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.canSave ? Color(red: 1.0, green: 0.27, blue: 0.27) : Color.gray)
                                        .shadow(color: viewModel.canSave ? Color(red: 1.0, green: 0.27, blue: 0.27).opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Time Capsule Link
                Button(action: {
                    viewModel.showTimeCapsule()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "infinity")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                        
                        Text("Zaman Kapsülünü Araç Geçen Yıl\nNe Dedin?")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96)) // Açık gri
        }
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $viewModel.showingPreviousAnswer) {
            PreviousAnswerView(viewModel: viewModel)
        }
        .alert("Geçmiş Cevap Bulunamadı", isPresented: $viewModel.showingNoPreviousAnswerAlert) {
            Button("Tamam") {
                viewModel.hideNoPreviousAnswerAlert()
            }
        } message: {
            Text("Geçen sene verdiğiniz bir cevap bulunmamaktadır.")
        }
    }
}

#Preview {
    TodayViewExact()
}
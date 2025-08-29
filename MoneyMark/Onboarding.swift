import SwiftUI

// MARK: - Shared Data Model
@MainActor
final class OnboardingData: ObservableObject {
    @Published var name: String = ""
    @Published var brand: String = ""

    @Published var monthlyCars: Int? = nil

    @Published var flat: Double? = nil
    @Published var front: Double? = nil
    @Published var back: Double? = nil

    @Published var monthlyGoal: Double? = nil
}

// MARK: - Common Styles
struct OBCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1)))
    }
}

extension View {
    func simpleNextButton(_ title: String = "Next",
                          disabled: Bool = false,
                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(disabled ? Color.yellow.opacity(0.4) : Color.yellow)
        .foregroundStyle(.black)
        .clipShape(Capsule())
        .disabled(disabled)
    }
}

// MARK: - Step 1: Name & Brand
struct OnboardingNameBrand: View {
    @StateObject private var data = OnboardingData()
    @FocusState private var focused: Field?
    @State private var goNext = false

    enum Field { case name, brand }

    var body: some View {
        VStack(spacing: 24) {
            header("Welcome")

            OBCard {
                TextField("Your name", text: $data.name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focused, equals: .name)
                    .tint(.yellow)
                    .foregroundStyle(.white)

                TextField("Brand (e.g., Nissan, Toyota…)", text: $data.brand)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($focused, equals: .brand)
                    .tint(.yellow)
                    .foregroundStyle(.white)
            }

            .navigationDestination(isPresented: $goNext) {
                OnboardingMonthlyCars()
                    .environmentObject(data)
            }
            

            Spacer()

            simpleNextButton("Continue",
                             disabled: data.name.trimmingCharacters(in: .whitespaces).isEmpty ||
                                       data.brand.trimmingCharacters(in: .whitespaces).isEmpty) {
                goNext = true
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .background(Color.black.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { title("Setup") } }
        .onAppear { focused = .name }
    }

    @ViewBuilder private func header(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private func title(_ text: String) -> some View {
        Text(text).foregroundStyle(.white)
    }
}

// MARK: - Step 2: Monthly Cars
struct OnboardingMonthlyCars: View {
    @EnvironmentObject var data: OnboardingData
    @State private var goNext = false

    var body: some View {
        VStack(spacing: 24) {
            header("Monthly Volume")

            OBCard {
                Text("How many cars do you sell in a month?")
                    .font(.headline)
                    .foregroundStyle(.white)

                Stepper(value: Binding(get: { data.monthlyCars ?? 10 },
                                       set: { data.monthlyCars = $0 }),
                        in: 0...200) {
                    Text("\(data.monthlyCars ?? 10) cars")
                        .foregroundStyle(.white)
                }
            }

            .navigationDestination(isPresented: $goNext) {
                OnboardingMonthlyCars()
                    .environmentObject(data)
            }


            Spacer()

            simpleNextButton("Continue") {
                if data.monthlyCars == nil { data.monthlyCars = 10 }
                goNext = true
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .background(Color.black.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { title("Setup") } }
    }

    @ViewBuilder private func header(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    @ViewBuilder private func title(_ text: String) -> some View {
        Text(text).foregroundStyle(.white)
    }
}

// MARK: - Step 3: Pay Plan
struct OnboardingPayPlan: View {
    @EnvironmentObject var data: OnboardingData
    @State private var goNext = false
    
    var body: some View {
        VStack(spacing: 24) {
            header("Pay Plan")
            
            OBCard {
                Text("Enter your typical pay by deal")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                moneyRow(label: "Flat", value: $data.flat)
                moneyRow(label: "Front", value: $data.front)
                moneyRow(label: "Back", value: $data.back)
            }
            
            .navigationDestination(isPresented: $goNext) {
                OnboardingMonthlyCars()
                    .environmentObject(data)
            }
            
            
            Spacer()
            
            let missing = [data.flat, data.front, data.back].contains(where: { $0 == nil })
            simpleNextButton("Continue", disabled: missing) {
                goNext = true
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .background(Color.black.ignoresSafeArea())
        .toolbar { ToolbarItem(placement: .principal) { title("Setup") } }
    }
    
    @ViewBuilder private func moneyRow(label: String, value: Binding<Double?>) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            TextField("$0", value: value, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .tint(.yellow)
                .foregroundStyle(.white)
                .frame(width: 160)
        }
        .padding(.vertical, 6)
    }
    
    @ViewBuilder private func header(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    @ViewBuilder private func title(_ text: String) -> some View {
        Text(text).foregroundStyle(.white)
    }
    
    
    // MARK: - Step 4: Monthly Goal
    struct OnboardingMonthlyGoal: View {
        @EnvironmentObject var data: OnboardingData
        @State private var goNext = false
        
        var body: some View {
            VStack(spacing: 24) {
                header("Goal")
                
                OBCard {
                    Text("What’s your monthly commission goal?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    HStack {
                        Text("Goal")
                            .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                        TextField("$0", value: $data.monthlyGoal, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .tint(.yellow)
                            .foregroundStyle(.white)
                            .frame(width: 180)
                    }
                    .padding(.vertical, 6)
                }
                
                .navigationDestination(isPresented: $goNext) {
                    OnboardingMonthlyCars()
                        .environmentObject(data)
                }
                
                
                Spacer()
                
                simpleNextButton("Review", disabled: data.monthlyGoal == nil) {
                    goNext = true
                }
                .padding(.horizontal, 20)
            }
            .padding(20)
            .background(Color.black.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .principal) { title("Setup") } }
        }
        
        @ViewBuilder private func header(_ text: String) -> some View {
            Text(text)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        @ViewBuilder private func title(_ text: String) -> some View {
            Text(text).foregroundStyle(.white)
        }
    }
    
    // MARK: - Step 5: Summary / Finish
    struct OnboardingSummary: View {
        @EnvironmentObject var data: OnboardingData
        
        var body: some View {
            VStack(spacing: 20) {
                Text("All set, \(data.name)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                OBCard {
                    summaryRow("Brand", data.brand)
                    summaryRow("Monthly Cars", "\(data.monthlyCars ?? 0)")
                    summaryRow("Flat", currency(data.flat))
                    summaryRow("Front", currency(data.front))
                    summaryRow("Back", currency(data.back))
                    Divider().overlay(.white.opacity(0.2))
                    summaryRow("Monthly Goal", currency(data.monthlyGoal))
                }
                
                Spacer()
                
                Button {
                    // TODO: Persist to storage, then move to main app (e.g., dashboard)
                    // Example: set an @AppStorage flag and present your main TabView
                } label: {
                    Text("Finish")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(.yellow)
                .foregroundStyle(.black)
                .clipShape(Capsule())
                .padding(.horizontal, 20)
            }
            .padding(20)
            .background(Color.black.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .principal) { Text("Review").foregroundStyle(.white) } }
        }
        
        @ViewBuilder private func summaryRow(_ label: String, _ value: String) -> some View {
            HStack {
                Text(label).foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(value).foregroundStyle(.white)
            }
            .padding(.vertical, 4)
        }
        
        private func currency(_ v: Double?) -> String {
            guard let v else { return "-" }
            return v.formatted(.currency(code: "USD"))
        }
    }
    #Preview {
        OnboardingGoal()
            .environmentObject(ProfileStore())  // 👈 add mock store here
            .environmentObject(DealStore())     // 👈 and here
    }
}

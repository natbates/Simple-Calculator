import SwiftUI

struct ContentView: View {
    @State private var currentInput: String = ""
    @State private var backgroundColor: Color = Color(red: 165 / 255.0, green: 182 / 255.0, blue: 134 / 255.0)
    @State private var history: [String] = []
    @State private var selectedOperator: String? = nil
    @State private var displayingResult: Bool = false
    @State private var showoperator: Bool = false
    
    var body: some View {
        
        ZStack{
            
            VStack {
                
                Text("Calculator App made by Nathaniel Bates")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white)
                    .offset(x: 0, y: 20)
                
                Spacer() // Pushes buttons towards the bottom
                

                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Spacer()
                        ScrollViewReader { scrollViewProxy in // ScrollViewReader capturing ScrollViewProxy
                            if String(history.joined() + (selectedOperator ?? "")) != String((evaluateExpression().rounded(toPlaces: 7))){
                                if displayingResult || currentInput.isEmpty
                                {
                                    Text(currentInput.isEmpty ? "\(evaluateExpression())" : "\(Double(currentInput)?.rounded(toPlaces: 7) ?? 0.0)".strippingTrailingZeros())
                                        .font(.system(size: 80))
                                        .padding()
                                        .foregroundColor(Color.white)
                                        .frame(alignment: .trailing) // Align content to the trailing edge
                                        .id("scrollToEnd") // Give an identifier to scroll to the end
                                        .onChange(of: history) { // Trigger scroll animation when history changes
                                            withAnimation {
                                                scrollViewProxy.scrollTo("scrollToEnd", anchor: .leading)
                                            }
                                        }
                                    
                                } else {
                                    Text("\(currentInput)")
                                        .font(.system(size: 80))
                                        .padding()
                                        .foregroundColor(Color.white)
                                        .frame(alignment: .trailing) // Align content to the trailing edge
                                        .id("scrollToEnd") // Give an identifier to scroll to the end
                                        .onChange(of: history) { // Trigger scroll animation when history changes
                                            withAnimation {
                                                scrollViewProxy.scrollTo("scrollToEnd", anchor: .leading)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .offset(x: 16, y: 190)
                    .frame(width: geometry.size.width - 30, height: 80)
                }
                
                Capsule(style: .circular)
                    .fill(Color.white)
                    .frame(width: 300, height: 4)
                    .offset(y: 110)
                
                
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Spacer()
                        ScrollViewReader { scrollViewProxy in
                            let formattedText = formatHistory(history: history)
                            Text(formattedText)
                                .font(.system(size: 20))
                                .padding(.leading, 25)
                                .padding(.bottom, 20)
                                .foregroundColor(Color.gray)
                                .frame(alignment: .trailing)
                                .id("scrollToEnd")
                                .onChange(of: history) {
                                    withAnimation {
                                        scrollViewProxy.scrollTo("scrollToEnd", anchor: .trailing)
                                    }
                                }
                        }
                    }
                    .offset(x: 16, y: 140)
                    .frame(width: geometry.size.width - 30, height: 30)
                }

                
                HStack(spacing: 20) {
                    CalculatorButton(text: "AC", selected: false, action: { // Pass selected as false for number buttons
                        self.clear()
                    })
                    
                    CalculatorButton(text: "←", selected: false, action: {
                        
                        if self.history.count > 2{
                            self.history = history.filter { !$0.isEmpty && !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                            self.history.removeLast()
                            self.history.removeLast()
                            self.currentInput = String(self.evaluateExpression())
                            
                        } else {
                            self.clear()
                        }
                    })
                    
                    CalculatorButton(text: "±", selected: false, action: {
                        if let number = Double(self.currentInput){
                            if displayingResult == false{
                                self.currentInput = String(number * -1)
                                
                            }
                        }
                    })
                    
                    CalculatorButton(text: "%", selected: false, action: {
                        
                        if displayingResult == false
                        {
                            if let lastHistory = history.last, let _ = Double(lastHistory) {
                                
                            } else {
                                if String(currentInput) != ""{
                                    currentInput = String((Double(currentInput) ?? 0.0) * 0.01)
                                    print(history)
                                }
                            }
                        } else{
                            var num: Double
                            num = evaluateExpression() * 0.01
                            self.clear()
                            currentInput = String(num)
                            displayingResult = false
                            print(history)
                        }
                    })
                }
                
                HStack(spacing: 20) {
                    // Buttons for numbers 1-3
                    ForEach([7, 8, 9], id: \.self) { number in
                        CalculatorButton(text: "\(number)", selected: false, action: { // Pass selected as false for number buttons
                            self.appendNumber("\(number)")
                        })
                    }
                    // Button for addition
                    CalculatorButton(text: "+", selected: selectedOperator == "+", action: {
                        self.selectOperator("+")
                    })
                }
                HStack(spacing: 20) {
                    ForEach([4, 5, 6], id: \.self) { number in
                        CalculatorButton(text: "\(number)", selected: false, action: { // Pass selected as false for number buttons
                            self.appendNumber("\(number)")
                        })
                    }
                    CalculatorButton(text: "-", selected: selectedOperator == "-", action: {
                        self.selectOperator("-")
                    })
                }
                HStack(spacing: 20) {
                    ForEach([1, 2, 3], id: \.self) { number in
                        CalculatorButton(text: "\(number)", selected: false, action: { // Pass selected as false for number buttons
                            self.appendNumber("\(number)")
                        })
                    }
                    CalculatorButton(text: "/", selected: selectedOperator == "/", action: {
                        self.selectOperator("/")
                    })
                }
                HStack(spacing: 20) {
                    CalculatorButton(text: ".", selected: false, action: { // Pass selected as false for the decimal button
                        self.appendNumber(".")
                    })
                    CalculatorButton(text: "0", selected: false, action: { // Pass selected as false for the number 0 button
                        self.appendNumber("0")
                    })
                    CalculatorButton(text: "=", selected: false, action: {
                        self.selectOperator("=")
                    })
                    CalculatorButton(text: "*", selected: selectedOperator == "*", action: {
                        self.selectOperator("*")
                    })
                }
                .padding(.bottom, 20)
            }
            .background(backgroundColor)

            RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: -10, trailing: 15))

 
        }
        
        .edgesIgnoringSafeArea(.horizontal) // Ignore safe area to fill the entire screen

    }
    
    func formatHistory(history: [String]) -> String {
        var formattedText = ""
        var lastNumber: Double?
        var isFirst = true
        
        for (index, element) in history.enumerated() {
            if let number = Double(element) {
                
                if lastNumber == nil {
                    lastNumber = number
                    if isFirst {
                        formattedText += "\(lastNumber!) "
                    }
                    
                } else {
                    let operatorSymbol = history[index - 1]
                    formattedText += "\(operatorSymbol) \(number)"
                    var result: Double
                    switch operatorSymbol {
                    case "+": result = lastNumber! + number
                    case "-": result = lastNumber! - number
                    case "*": result = lastNumber! * number
                    case "/": result = lastNumber! / number
                    default: result = 0.0
                    }
                    formattedText += " = \(result.rounded(toPlaces: 7)) "
                    lastNumber = result
                }
                isFirst = false
            }
        }
        
        let pattern = "(\\d+)\\.0\\b"
        let regex = try! NSRegularExpression(pattern: pattern)

        // Replace numbers ending with .0 with their integer part
        let range = NSRange(location: 0, length: formattedText.utf16.count)
        let modifiedText = regex.stringByReplacingMatches(in: formattedText, options: [], range: range, withTemplate: "$1")

        return modifiedText
    }

    private func appendNumber(_ number: String) {
        
        if displayingResult{
            self.clear()
            displayingResult = false
        }
        
        if let selectedOperator = self.selectedOperator {
            self.history = history.filter { !$0.isEmpty && !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            if selectedOperator != "" && history.count > 0{
                history.append(selectedOperator)
            }
            self.selectOperator("")}
        
        currentInput += number
        
    }
    
    private func selectOperator(_ operator: String) {
        
        if selectedOperator == `operator` {
            selectedOperator = "" // Set selectedOperator to an empty string if the same operator is selected again
            displayingResult = false;
            return // Don't do anything if the same operator is selected again
        }
        else{
            
            if `operator` == "=" {
                if let lastHistory = history.last, let _ = Double(lastHistory) {
                    
                } else{
                    history.append(currentInput)
                }
                // Perform calculation immediately when equals button is pressed
                if let lastElement = history.last, !["+", "-", "*", "/"].contains(lastElement), !lastElement.isEmpty {
                    currentInput = String(evaluateExpression())
                    displayingResult = true
                    selectedOperator = nil
                }
            } else {
                
                if displayingResult == false{
                    history.append(currentInput.strippingTrailingZeros().strippingHeadingZeros())
                    selectedOperator = `operator`
                    currentInput = ""
                } else {
                    displayingResult = false
                    selectedOperator = `operator`
                    currentInput = ""
                }
            }
            currentInput = ""
        }
        
        self.history = history.filter { !$0.isEmpty && !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if history.count > 0{
            showoperator = true
        } else {
            showoperator = false
        }
        
    }
    
    private func clear() {
        currentInput = ""
        history.removeAll()
        selectedOperator = nil
    }
    
    private func evaluateExpression() -> Double {
        let history = history.filter { !$0.isEmpty && !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !history.isEmpty else { return 0 }
            
        var total: Double = 0
        var currentOperation: String?
    
        for element in history {
            if let number = Double(element) {
                    if let operation = currentOperation {
                        switch operation {
                        case "+":
                            total += number
                        case "-":
                            total -= number
                        case "*":
                            total *= number
                        case "/":
                            if number != 0 {
                                total /= number
                            } else {
                                print("Error: Division by zero")
                                return 0
                            }
                        default:
                            print("Error: Invalid operation")
                            return 0
                        }
                        currentOperation = nil
                    } else {
                        total = number
                    }
                } else {
                    
                    currentOperation = element
                }
            }
        
        print("Result: ", total.roundedWithoutTrailingZeros(toPlaces: 7))
        return total.roundedWithoutTrailingZeros(toPlaces: 7)
    }
}

struct CalculatorButton: View {
    let text: String
    let selected: Bool // Indicates whether the button is selected
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .padding()
                .frame(width: 72, height: 72)
                .background(selected ? Color.orange : Color.white) // Change background color based on selection
                .foregroundColor(.black)
                .cornerRadius(15)
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func strippingTrailingZeros() -> String {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 16 // Adjust this as per your requirement
            return String(format: "%g", self)
        }
    
    func roundedWithoutTrailingZeros(toPlaces places: Int) -> Double {
            let roundedValue = self.rounded(toPlaces: places)
            let roundedString = String(format: "%.\(places)f", roundedValue)
            return Double(roundedString) ?? 0.0
        }
}

extension String {
    func strippingTrailingZeros() -> String {
        if let doubleValue = Double(self) {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 16 // Adjust this as per your requirement
            return formatter.string(from: NSNumber(value: doubleValue)) ?? ""
        }
        return ""
    }
    
    func strippingHeadingZeros() -> String {
                // Check if the string is a valid number
        if let doubleValue = Double(self) {
            // Convert the double value back to string to remove leading zeros
            let trimmedString = String(format: "%g", doubleValue)
            return trimmedString
        }
        return self // Return original string if it's not a valid number
            
    }
}

extension Array {
    func element(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

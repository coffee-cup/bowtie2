//
//  ColorPickerView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-28.
//

import SwiftUI

struct ColorPickerViewRepresentable: UIViewControllerRepresentable {
    @Binding var colour: Color
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate {
        var parent: ColorPickerViewRepresentable
        
        init(_ parent: ColorPickerViewRepresentable) {
            self.parent = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            self.parent.colour = Color(viewController.selectedColor.cgColor)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
//            print("DID FINISH")
        }
    }
    
    typealias UIViewControllerType = UIColorPickerViewController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ColorPickerViewRepresentable>) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        
        picker.selectedColor = UIColor(colour)
        picker.delegate = context.coordinator
        picker.supportsAlpha = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        // code
    }
}

struct ColorPickerView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var colour: Color

    var body: some View {
        ZStack {
            ColorPickerViewRepresentable(colour: $colour)

            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .padding()
                    }
                }
                .padding(.top)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    @State static var colour: Color = Color.blue
    
    static var previews: some View {
        ColorPickerView(colour: $colour)
    }
}

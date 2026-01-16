import SwiftUI
import PhotosUI

struct VerificationView: View {
    let contract: Contract
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isSubmitting = false
    @State private var showCamera = false
    @State private var showSuccess = false
    @State private var showFailure = false

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: RTTheme.Spacing.lg) {
                    Text("提交\(contract.verificationType.displayName)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(RTTheme.Colors.textPrimary)

                    // 图片预览
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                                    .stroke(RTTheme.Colors.primary.opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                            .fill(RTTheme.Colors.surface)
                            .frame(height: 200)
                            .overlay {
                                VStack(spacing: RTTheme.Spacing.sm) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                    Text("选择或拍摄照片")
                                        .font(.system(size: 15))
                                }
                                .foregroundStyle(RTTheme.Colors.textTertiary)
                            }
                    }

                    // 操作按钮
                    HStack(spacing: RTTheme.Spacing.md) {
                        Button(action: { showCamera = true }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("拍照")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.surface)
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("相册")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.surface)
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }
                    }

                    Spacer()

                    // 提交按钮
                    Button(action: submit) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("提交验证")
                            }
                        }
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RTTheme.Spacing.md)
                        .background(
                            selectedImage == nil || isSubmitting
                                ? AnyShapeStyle(RTTheme.Colors.surface)
                                : AnyShapeStyle(RTTheme.Colors.primaryGradient)
                        )
                        .foregroundStyle(selectedImage == nil || isSubmitting ? RTTheme.Colors.textTertiary : .white)
                        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    }
                    .disabled(selectedImage == nil || isSubmitting)
                }
                .padding(RTTheme.Spacing.lg)
            }
            .navigationTitle("验证")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $selectedImage)
            }
            .fullScreenCover(isPresented: $showSuccess) {
                RTSuccessCelebration(
                    isShowing: $showSuccess,
                    amount: Int(NSDecimalNumber(decimal: contract.pledgeAmount).doubleValue)
                )
                .onDisappear {
                    dismiss()
                }
            }
            .fullScreenCover(isPresented: $showFailure) {
                RTFailureCelebration(
                    isShowing: $showFailure,
                    amount: Int(NSDecimalNumber(decimal: contract.pledgeAmount).doubleValue),
                    shameTarget: contract.shameTarget
                )
                .onDisappear {
                    dismiss()
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true
        // TODO: 上传图片并调用AI验证
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isSubmitting = false

            // 模拟验证结果 (随机成功/失败用于演示)
            let success = Bool.random()
            if success {
                showSuccess = true
            } else {
                showFailure = true
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    VerificationView(contract: Contract(
        id: "1",
        userId: "user1",
        title: "测试",
        description: "",
        pledgeAmount: 100,
        deadline: Date(),
        verificationType: .photo,
        status: .active,
        shameTarget: ShameTarget(name: "前任", phone: "13800138000", relationship: .ex),
        createdAt: Date()
    ))
}

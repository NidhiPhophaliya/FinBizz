import { SignUp } from "@clerk/nextjs";

const appearance = {
  variables: {
    colorBackground: "#222431",
    colorText: "#ffffff",
    colorPrimary: "#42a5f5",
    colorInputBackground: "#272937",
    colorInputText: "#ffffff",
    borderRadius: "8px",
  },
};

export default function SignUpPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-bg-primary p-4">
      <SignUp appearance={appearance} />
    </div>
  );
}

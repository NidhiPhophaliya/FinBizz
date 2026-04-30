import { SignIn } from "@clerk/nextjs";

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

export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-bg-primary p-4">
      <SignIn appearance={appearance} />
    </div>
  );
}

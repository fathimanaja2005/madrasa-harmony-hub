import { Button } from "@/components/ui/button";
import { useNavigate } from "react-router-dom";
import { BookOpen, Users, Award } from "lucide-react";

const Index = () => {
  const navigate = useNavigate();

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-background via-secondary to-background">
      {/* Hero Section */}
      <div className="flex-1 flex items-center justify-center px-4 py-20">
        <div className="max-w-4xl mx-auto text-center space-y-8">
          <div className="w-20 h-20 mx-auto bg-primary rounded-full flex items-center justify-center mb-6">
            <span className="text-5xl">🕌</span>
          </div>
          
          <h1 className="text-5xl md:text-6xl font-bold text-primary mb-4">
            Madrasa Management System
          </h1>
          
          <p className="text-xl md:text-2xl text-muted-foreground max-w-2xl mx-auto">
            Complete Islamic education management platform for students, teachers, and administrators
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mt-8">
            <Button 
              size="lg" 
              className="text-lg px-8"
              onClick={() => navigate("/auth")}
            >
              Sign In
            </Button>
            <Button 
              size="lg" 
              variant="outline" 
              className="text-lg px-8"
              onClick={() => navigate("/auth")}
            >
              Create Account
            </Button>
          </div>

          {/* Features */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16">
            <div className="p-6 bg-card rounded-lg border border-border hover:border-primary/50 transition-colors">
              <div className="w-12 h-12 mx-auto mb-4 bg-primary/10 rounded-full flex items-center justify-center">
                <BookOpen className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-bold mb-2">Digital Library</h3>
              <p className="text-muted-foreground">Access Quran, Tajweed, Islamic studies and more</p>
            </div>

            <div className="p-6 bg-card rounded-lg border border-border hover:border-primary/50 transition-colors">
              <div className="w-12 h-12 mx-auto mb-4 bg-primary/10 rounded-full flex items-center justify-center">
                <Award className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-bold mb-2">Hifz Tracking</h3>
              <p className="text-muted-foreground">Monitor memorization progress and achievements</p>
            </div>

            <div className="p-6 bg-card rounded-lg border border-border hover:border-primary/50 transition-colors">
              <div className="w-12 h-12 mx-auto mb-4 bg-primary/10 rounded-full flex items-center justify-center">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-bold mb-2">Complete Management</h3>
              <p className="text-muted-foreground">Fee management, attendance, and assignments</p>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="py-6 border-t border-border">
        <p className="text-center text-muted-foreground">
          © 2024 Madrasa Management System. All rights reserved.
        </p>
      </footer>
    </div>
  );
};

export default Index;

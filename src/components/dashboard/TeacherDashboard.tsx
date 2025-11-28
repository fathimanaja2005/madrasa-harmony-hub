import { User } from "@supabase/supabase-js";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";
import { useNavigate } from "react-router-dom";
import { useToast } from "@/hooks/use-toast";
import { Users, BookOpen, CheckSquare, Upload, LogOut } from "lucide-react";

interface TeacherDashboardProps {
  user: User;
}

const TeacherDashboard = ({ user }: TeacherDashboardProps) => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    toast({
      title: "Signed out",
      description: "You have been logged out successfully",
    });
    navigate("/auth");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-secondary to-background">
      {/* Header */}
      <header className="bg-card border-b border-border sticky top-0 z-10">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center">
              <span className="text-2xl">🕌</span>
            </div>
            <h1 className="text-2xl font-bold text-primary">Teacher Portal</h1>
          </div>
          <Button onClick={handleSignOut} variant="outline" size="sm">
            <LogOut className="mr-2 h-4 w-4" />
            Sign Out
          </Button>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-foreground mb-2">Welcome, Teacher!</h2>
          <p className="text-muted-foreground">{user.email}</p>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <Card className="border-primary/20 hover:border-primary/40 transition-colors">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Students</CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-primary">45</div>
              <p className="text-xs text-muted-foreground">Under your guidance</p>
            </CardContent>
          </Card>

          <Card className="border-primary/20 hover:border-primary/40 transition-colors">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Classes Today</CardTitle>
              <BookOpen className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-primary">4</div>
              <p className="text-xs text-muted-foreground">Scheduled</p>
            </CardContent>
          </Card>

          <Card className="border-primary/20 hover:border-primary/40 transition-colors">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Pending Reviews</CardTitle>
              <CheckSquare className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-accent">12</div>
              <p className="text-xs text-muted-foreground">Assignments to grade</p>
            </CardContent>
          </Card>

          <Card className="border-primary/20 hover:border-primary/40 transition-colors">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Resources</CardTitle>
              <Upload className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-primary">28</div>
              <p className="text-xs text-muted-foreground">Uploaded this month</p>
            </CardContent>
          </Card>
        </div>

        {/* Main Sections */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Today's Classes</CardTitle>
              <CardDescription>Your teaching schedule</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between p-3 bg-secondary rounded-lg">
                  <div>
                    <p className="font-medium">Quran Recitation - Class 5A</p>
                    <p className="text-sm text-muted-foreground">9:00 AM - 10:00 AM</p>
                  </div>
                  <Button size="sm" variant="outline">Start</Button>
                </div>
                <div className="flex items-center justify-between p-3 bg-secondary rounded-lg">
                  <div>
                    <p className="font-medium">Tajweed Rules - Class 6B</p>
                    <p className="text-sm text-muted-foreground">10:30 AM - 11:30 AM</p>
                  </div>
                  <Button size="sm" variant="outline">Start</Button>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Pending Assignments</CardTitle>
              <CardDescription>Submissions awaiting review</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between p-3 bg-secondary rounded-lg">
                  <div>
                    <p className="font-medium">Surah Al-Baqarah Recitation</p>
                    <p className="text-sm text-muted-foreground">8 submissions</p>
                  </div>
                  <Button size="sm">Review</Button>
                </div>
                <div className="flex items-center justify-between p-3 bg-secondary rounded-lg">
                  <div>
                    <p className="font-medium">Islamic History Essay</p>
                    <p className="text-sm text-muted-foreground">15 submissions</p>
                  </div>
                  <Button size="sm">Review</Button>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Student Hifz Progress</CardTitle>
              <CardDescription>Track memorization status</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <Button variant="outline" className="w-full justify-start">
                  <Users className="mr-2 h-4 w-4" />
                  View All Students
                </Button>
                <Button variant="outline" className="w-full justify-start">
                  <CheckSquare className="mr-2 h-4 w-4" />
                  Update Progress
                </Button>
                <Button variant="outline" className="w-full justify-start">
                  <Upload className="mr-2 h-4 w-4" />
                  Review Audio Submissions
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
              <CardDescription>Common tasks</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <Button className="w-full">
                  <Upload className="mr-2 h-4 w-4" />
                  Upload Lesson Material
                </Button>
                <Button className="w-full" variant="outline">
                  <CheckSquare className="mr-2 h-4 w-4" />
                  Create Assignment
                </Button>
                <Button className="w-full" variant="outline">
                  <Users className="mr-2 h-4 w-4" />
                  Mark Attendance
                </Button>
                <Button className="w-full" variant="outline">
                  <BookOpen className="mr-2 h-4 w-4" />
                  Send Announcement
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  );
};

export default TeacherDashboard;
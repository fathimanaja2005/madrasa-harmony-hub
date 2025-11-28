-- Create app_role enum
CREATE TYPE public.app_role AS ENUM ('admin', 'teacher', 'student');

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create user_roles table
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role public.app_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create security definer function to check roles
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
    AND role = _role
  )
$$;

-- Create classes table
CREATE TABLE public.classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  monthly_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- Create students table
CREATE TABLE public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  class_id UUID REFERENCES public.classes(id) ON DELETE SET NULL,
  student_id TEXT UNIQUE NOT NULL,
  admission_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- Create teachers table
CREATE TABLE public.teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  teacher_id TEXT UNIQUE NOT NULL,
  specialization TEXT,
  join_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

-- Create monthly_fees table
CREATE TABLE public.monthly_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  due_month DATE NOT NULL,
  due_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, due_month)
);

ALTER TABLE public.monthly_fees ENABLE ROW LEVEL SECURITY;

-- Create fee_payments table
CREATE TABLE public.fee_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  monthly_fee_id UUID REFERENCES public.monthly_fees(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT,
  transaction_id TEXT,
  payment_date TIMESTAMPTZ DEFAULT NOW(),
  receipt_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.fee_payments ENABLE ROW LEVEL SECURITY;

-- Create library_content table
CREATE TABLE public.library_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('quran', 'tajweed', 'tafseer', 'hadith', 'islamic_studies')),
  content_type TEXT NOT NULL CHECK (content_type IN ('pdf', 'audio', 'video')),
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.library_content ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert profiles"
  ON public.profiles FOR INSERT
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for user_roles
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all roles"
  ON public.user_roles FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for classes
CREATE POLICY "Everyone can view classes"
  ON public.classes FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage classes"
  ON public.classes FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for students
CREATE POLICY "Students can view their own data"
  ON public.students FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins and teachers can view all students"
  ON public.students FOR SELECT
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'teacher'));

CREATE POLICY "Admins can manage students"
  ON public.students FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for teachers
CREATE POLICY "Teachers can view their own data"
  ON public.teachers FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all teachers"
  ON public.teachers FOR SELECT
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage teachers"
  ON public.teachers FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for monthly_fees
CREATE POLICY "Students can view their own fees"
  ON public.monthly_fees FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.students
      WHERE students.id = monthly_fees.student_id
      AND students.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage all fees"
  ON public.monthly_fees FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for fee_payments
CREATE POLICY "Students can view their own payments"
  ON public.fee_payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.monthly_fees mf
      JOIN public.students s ON s.id = mf.student_id
      WHERE mf.id = fee_payments.monthly_fee_id
      AND s.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage all payments"
  ON public.fee_payments FOR ALL
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies for library_content
CREATE POLICY "Authenticated users can view library content"
  ON public.library_content FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins and teachers can manage library content"
  ON public.library_content FOR ALL
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'teacher'));

-- Trigger to update updated_at timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_classes_updated_at
  BEFORE UPDATE ON public.classes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_students_updated_at
  BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_teachers_updated_at
  BEFORE UPDATE ON public.teachers
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_monthly_fees_updated_at
  BEFORE UPDATE ON public.monthly_fees
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_library_content_updated_at
  BEFORE UPDATE ON public.library_content
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Function to handle new user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
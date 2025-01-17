; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes --check-globals
; call site specific analysis is enabled

; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-enable-call-site-specific-deduction=true -attributor-manifest-internal  -attributor-annotate-decl-cs  -S < %s | FileCheck %s --check-prefixes=CHECK,TUNIT

; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-enable-call-site-specific-deduction=true -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC

define dso_local i32 @test_range1(i32 %0) #0 {
; CHECK-LABEL: define {{[^@]+}}@test_range1
; CHECK-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP0]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[TMP3:%.*]], label [[TMP4:%.*]]
; CHECK:       3:
; CHECK-NEXT:    br label [[TMP5:%.*]]
; CHECK:       4:
; CHECK-NEXT:    br label [[TMP5]]
; CHECK:       5:
; CHECK-NEXT:    [[DOT0:%.*]] = phi i32 [ 100, [[TMP3]] ], [ 0, [[TMP4]] ]
; CHECK-NEXT:    ret i32 [[DOT0]]
;
  %2 = icmp ne i32 %0, 0
  br i1 %2, label %3, label %4

3:                                                ; preds = %1
  br label %5

4:                                                ; preds = %1
  br label %5

5:                                                ; preds = %4, %3
  %.0 = phi i32 [ 100, %3 ], [ 0, %4 ]
  ret i32 %.0
}

define i32 @test_range2(i32 %0) #0 {
; CHECK-LABEL: define {{[^@]+}}@test_range2
; CHECK-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP0]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[TMP3:%.*]], label [[TMP4:%.*]]
; CHECK:       3:
; CHECK-NEXT:    br label [[TMP5:%.*]]
; CHECK:       4:
; CHECK-NEXT:    br label [[TMP5]]
; CHECK:       5:
; CHECK-NEXT:    [[DOT0:%.*]] = phi i32 [ 100, [[TMP3]] ], [ 200, [[TMP4]] ]
; CHECK-NEXT:    ret i32 [[DOT0]]
;
  %2 = icmp ne i32 %0, 0
  br i1 %2, label %3, label %4

3:                                                ; preds = %1
  br label %5

4:                                                ; preds = %1
  br label %5

5:                                                ; preds = %4, %3
  %.0 = phi i32 [ 100, %3 ], [ 200, %4 ]
  ret i32 %.0
}
define i32 @test(i32 %0, i32 %1) #0 {
; TUNIT-LABEL: define {{[^@]+}}@test
; TUNIT-SAME: (i32 [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP1]], 0
; TUNIT-NEXT:    br i1 [[TMP3]], label [[TMP4:%.*]], label [[TMP6:%.*]]
; TUNIT:       4:
; TUNIT-NEXT:    [[TMP5:%.*]] = call i32 @test_range1(i32 [[TMP0]])
; TUNIT-NEXT:    br label [[TMP8:%.*]]
; TUNIT:       6:
; TUNIT-NEXT:    [[TMP7:%.*]] = call i32 @test_range2(i32 [[TMP0]])
; TUNIT-NEXT:    br label [[TMP8]]
; TUNIT:       8:
; TUNIT-NEXT:    [[DOT0:%.*]] = phi i32 [ [[TMP5]], [[TMP4]] ], [ [[TMP7]], [[TMP6]] ]
; TUNIT-NEXT:    ret i32 [[DOT0]]
;
; CGSCC-LABEL: define {{[^@]+}}@test
; CGSCC-SAME: (i32 [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR1:[0-9]+]] {
; CGSCC-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP1]], 0
; CGSCC-NEXT:    br i1 [[TMP3]], label [[TMP4:%.*]], label [[TMP6:%.*]]
; CGSCC:       4:
; CGSCC-NEXT:    [[TMP5:%.*]] = call noundef i32 @test_range1(i32 [[TMP0]])
; CGSCC-NEXT:    br label [[TMP8:%.*]]
; CGSCC:       6:
; CGSCC-NEXT:    [[TMP7:%.*]] = call noundef i32 @test_range2(i32 [[TMP0]])
; CGSCC-NEXT:    br label [[TMP8]]
; CGSCC:       8:
; CGSCC-NEXT:    [[DOT0:%.*]] = phi i32 [ [[TMP5]], [[TMP4]] ], [ [[TMP7]], [[TMP6]] ]
; CGSCC-NEXT:    ret i32 [[DOT0]]
;
  %3 = icmp ne i32 %1, 0
  br i1 %3, label %4, label %6

4:                                                ; preds = %2
  %5 = call i32 @test_range1(i32 %0)
  br label %8

6:                                                ; preds = %2
  %7 = call i32 @test_range2(i32 %0)
  br label %8

8:                                                ; preds = %6, %4
  %.0 = phi i32 [ %5, %4 ], [ %7, %6 ]
  ret i32 %.0
}

define i32 @test_pcheck1(i32 %0) #0 {
; TUNIT-LABEL: define {{[^@]+}}@test_pcheck1
; TUNIT-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 1)
; TUNIT-NEXT:    [[TMP3:%.*]] = icmp slt i32 [[TMP2]], 101
; TUNIT-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; TUNIT-NEXT:    ret i32 [[TMP4]]
;
; CGSCC-LABEL: define {{[^@]+}}@test_pcheck1
; CGSCC-SAME: (i32 [[TMP0:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 1)
; CGSCC-NEXT:    [[TMP3:%.*]] = icmp slt i32 [[TMP2]], 101
; CGSCC-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; CGSCC-NEXT:    ret i32 [[TMP4]]
;
; TUNIT_ENABLED-LABEL: define {{[^@]+}}@test_pcheck1
; TUNIT_ENABLED-SAME: (i32 [[TMP0:%.*]])
; TUNIT_ENABLED-NEXT:    ret i32 1
  %2 = call i32 @test(i32 %0, i32 1)
  %3 = icmp slt i32 %2, 101
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @test_pcheck2(i32 %0) #0 {
; TUNIT-LABEL: define {{[^@]+}}@test_pcheck2
; TUNIT-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 0)
; TUNIT-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 99
; TUNIT-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; TUNIT-NEXT:    ret i32 [[TMP4]]
;
; CGSCC-LABEL: define {{[^@]+}}@test_pcheck2
; CGSCC-SAME: (i32 [[TMP0:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 0)
; CGSCC-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 99
; CGSCC-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; CGSCC-NEXT:    ret i32 [[TMP4]]
;
  %2 = call i32 @test(i32 %0, i32 0)
  %3 = icmp sgt i32 %2, 99
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @test_ncheck1(i32 %0) #0 {
; TUNIT-LABEL: define {{[^@]+}}@test_ncheck1
; TUNIT-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 1)
; TUNIT-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 50
; TUNIT-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; TUNIT-NEXT:    ret i32 [[TMP4]]
;
; CGSCC-LABEL: define {{[^@]+}}@test_ncheck1
; CGSCC-SAME: (i32 [[TMP0:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 1)
; CGSCC-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 50
; CGSCC-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; CGSCC-NEXT:    ret i32 [[TMP4]]
;
  %2 = call i32 @test(i32 %0, i32 1)
  %3 = icmp sgt i32 %2, 50
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @test_ncheck2(i32 %0) #0 {
; TUNIT-LABEL: define {{[^@]+}}@test_ncheck2
; TUNIT-SAME: (i32 [[TMP0:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 0)
; TUNIT-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 150
; TUNIT-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; TUNIT-NEXT:    ret i32 [[TMP4]]
;
; CGSCC-LABEL: define {{[^@]+}}@test_ncheck2
; CGSCC-SAME: (i32 [[TMP0:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[TMP2:%.*]] = call i32 @test(i32 [[TMP0]], i32 noundef 0)
; CGSCC-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], 150
; CGSCC-NEXT:    [[TMP4:%.*]] = zext i1 [[TMP3]] to i32
; CGSCC-NEXT:    ret i32 [[TMP4]]
;
  %2 = call i32 @test(i32 %0, i32 0)
  %3 = icmp sgt i32 %2, 150
  %4 = zext i1 %3 to i32
  ret i32 %4
}

attributes #0 = { noinline nounwind sspstrong uwtable}

; TUNIT_: !0 = !{i32 0, i32 101}
; TUNIT_: !1 = !{i32 100, i32 201}
;.
; TUNIT: attributes #[[ATTR0]] = { mustprogress nofree noinline norecurse nosync nounwind sspstrong willreturn memory(none) uwtable }
; TUNIT: attributes #[[ATTR1:[0-9]+]] = { nofree nosync nounwind willreturn }
;.
; CGSCC: attributes #[[ATTR0]] = { mustprogress nofree noinline norecurse nosync nounwind sspstrong willreturn memory(none) uwtable }
; CGSCC: attributes #[[ATTR1]] = { mustprogress nofree noinline nosync nounwind sspstrong willreturn memory(none) uwtable }
; CGSCC: attributes #[[ATTR2:[0-9]+]] = { willreturn }
;.

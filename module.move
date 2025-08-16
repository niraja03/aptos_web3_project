module myModule::ExamSeatingRandomizer {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::vector;

    /// Struct representing an exam seating arrangement
    struct ExamSeating has store, key {
        student_ids: vector<u64>,    // List of student IDs
        seat_assignments: vector<u64>, // Randomized seat assignments
        total_seats: u64,            // Total number of seats available
        is_randomized: bool,         // Flag to check if seating is randomized
    }

    /// Function to create a new exam seating arrangement
    public fun create_exam_seating(
        instructor: &signer, 
        student_ids: vector<u64>, 
        total_seats: u64
    ) {
        let student_count = vector::length(&student_ids);
        assert!(student_count <= total_seats, 1); // Ensure enough seats
        
        let exam_seating = ExamSeating {
            student_ids,
            seat_assignments: vector::empty<u64>(),
            total_seats,
            is_randomized: false,
        };
        move_to(instructor, exam_seating);
    }

    /// Function to randomize seating arrangement using timestamp-based pseudo-randomness
    public fun randomize_seating(instructor: &signer) acquires ExamSeating {
        let instructor_addr = signer::address_of(instructor);
        let exam_seating = borrow_global_mut<ExamSeating>(instructor_addr);
        
        assert!(!exam_seating.is_randomized, 2); // Prevent double randomization
        
        let student_count = vector::length(&exam_seating.student_ids);
        let seed = timestamp::now_microseconds();
        
        // Create seat assignments using simple pseudo-random algorithm
        let i = 0;
        while (i < student_count) {
            let random_seat = ((seed + (i as u64) * 1103515245 + 12345) % exam_seating.total_seats) + 1;
            vector::push_back(&mut exam_seating.seat_assignments, random_seat);
            i = i + 1;
        };
        
        exam_seating.is_randomized = true;
    }
}